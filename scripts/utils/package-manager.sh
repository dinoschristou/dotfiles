#!/bin/bash

# Package manager utility for handling centralized package configurations
# Reads YAML files and installs packages based on the current platform

# Initialize package manager
init_package_manager() {
    PACKAGE_CONFIG_DIR="$DOTFILES_DIR/scripts/packages/config"
    CUSTOM_CONFIG_DIR="$DOTFILES_DIR/scripts/packages/custom"
    
    # Create custom config directory if it doesn't exist
    mkdir -p "$CUSTOM_CONFIG_DIR"
    
    # Validate yq is available for YAML parsing
    if ! command_exists "yq"; then
        log_warn "yq not found - installing for YAML parsing..."
        install_yq
    fi
}

# Install yq for YAML parsing
install_yq() {
    case "$OS_NAME" in
        "macOS")
            brew install yq
            ;;
        "Ubuntu"|"Debian")
            # Install via snap or direct download
            if command_exists "snap"; then
                sudo snap install yq
            else
                install_yq_binary
            fi
            ;;
        "Arch")
            sudo pacman -S --noconfirm yq
            ;;
        "Fedora")
            sudo dnf install -y yq
            ;;
        *)
            install_yq_binary
            ;;
    esac
}

# Install yq binary directly
install_yq_binary() {
    local yq_version="v4.35.2"
    local yq_binary="yq_linux_amd64"
    
    if [[ "$ARCH" == "arm64" ]]; then
        yq_binary="yq_linux_arm64"
    fi
    
    log_info "Installing yq binary..."
    wget -O /tmp/yq "https://github.com/mikefarah/yq/releases/download/${yq_version}/${yq_binary}"
    chmod +x /tmp/yq
    sudo mv /tmp/yq /usr/local/bin/yq
}

# Get package name for current platform
get_package_name() {
    local config_file="$1"
    local package_key="$2"
    local category="$3"
    
    # Default package name is the key
    local package_name="$package_key"
    
    # Check if there's a platform-specific override
    local platform_override
    platform_override=$(yq eval ".${category}.${package_key}.${OS_NAME,,}" "$config_file" 2>/dev/null)
    
    if [[ "$platform_override" != "null" && -n "$platform_override" ]]; then
        package_name="$platform_override"
    fi
    
    echo "$package_name"
}

# Check if package should be skipped on current platform
should_skip_package() {
    local config_file="$1"
    local package_key="$2"  
    local category="$3"
    
    # Check skip_platforms array
    local skip_platforms
    skip_platforms=$(yq eval ".${category}.${package_key}.skip_platforms[]" "$config_file" 2>/dev/null)
    
    if [[ "$skip_platforms" =~ $OS_NAME ]]; then
        return 0  # Should skip
    fi
    
    return 1  # Should not skip
}

# Check if package requires manual installation
requires_manual_install() {
    local config_file="$1"
    local package_key="$2"
    local category="$3"
    
    local manual_install
    manual_install=$(yq eval ".${category}.${package_key}.manual_install" "$config_file" 2>/dev/null)
    
    [[ "$manual_install" == "true" ]]
}

# Check if package requires cask installation (macOS)
requires_cask_install() {
    local config_file="$1"
    local package_key="$2"
    local category="$3"
    
    local install_method
    install_method=$(yq eval ".${category}.${package_key}.install_method" "$config_file" 2>/dev/null)
    
    [[ "$install_method" == "cask" ]]
}

# Install packages from a configuration category
install_packages_from_config() {
    local config_file="$1"
    local category="$2"
    local description="$3"
    
    if [[ ! -f "$config_file" ]]; then
        log_error "Configuration file not found: $config_file"
        return 1
    fi
    
    log_step "Installing $description"
    
    # Get all package keys in the category
    local package_keys
    package_keys=$(yq eval ".${category} | keys | .[]" "$config_file" 2>/dev/null)
    
    if [[ -z "$package_keys" ]]; then
        log_warn "No packages found in category: $category"
        return 0
    fi
    
    # Track packages that need symlinks
    local -a symlink_packages=()
    
    # Install each package
    while IFS= read -r package_key; do
        if should_skip_package "$config_file" "$package_key" "$category"; then
            log_debug "Skipping $package_key on $OS_NAME"
            continue
        fi
        
        if requires_manual_install "$config_file" "$package_key" "$category"; then
            log_info "Package $package_key requires manual installation"
            continue
        fi
        
        if requires_cask_install "$config_file" "$package_key" "$category"; then
            if [[ "$OS_NAME" == "macOS" ]]; then
                local cask_name
                cask_name=$(get_package_name "$config_file" "$package_key" "$category")
                install_cask_package "$cask_name" "$package_key"
            else
                log_debug "Skipping cask package $package_key on non-macOS system"
            fi
            continue
        fi
        
        local package_name
        package_name=$(get_package_name "$config_file" "$package_key" "$category")
        
        # Handle array of packages (like build-essential on Fedora)
        if [[ "$package_name" == "["* ]]; then
            # Parse array and install each package
            local array_packages
            array_packages=$(echo "$package_name" | yq eval '.[]' -)
            while IFS= read -r pkg; do
                if [[ -n "$pkg" ]]; then
                    install_single_package "$pkg" "$package_key"
                fi
            done <<< "$array_packages"
        elif [[ -n "$package_name" && "$package_name" != "[]" ]]; then
            install_single_package "$package_name" "$package_key"
            
            # Check if package needs a symlink
            local symlink_as
            symlink_as=$(yq eval ".${category}.${package_key}.symlink_as" "$config_file" 2>/dev/null)
            if [[ "$symlink_as" != "null" && -n "$symlink_as" ]]; then
                symlink_packages+=("$package_name:$symlink_as")
            fi
            
            # Check if package needs post-install action
            local post_install
            post_install=$(yq eval ".${category}.${package_key}.post_install" "$config_file" 2>/dev/null)
            if [[ "$post_install" != "null" && -n "$post_install" ]]; then
                run_post_install_action "$post_install" "$package_key"
            fi
        fi
    done <<< "$package_keys"
    
    # Create symlinks for packages that need them
    for symlink_info in "${symlink_packages[@]}"; do
        local source_name="${symlink_info%:*}"
        local target_name="${symlink_info#*:}"
        create_package_symlink "$source_name" "$target_name"
    done
    
    log_success "$description installed successfully"
}

# Install a single package using the appropriate package manager
install_single_package() {
    local package_name="$1"
    local original_key="$2"
    
    case "$PACKAGE_MANAGER" in
        "brew")
            if ! brew list "$package_name" &>/dev/null; then
                log_info "Installing $package_name..."
                brew install "$package_name"
            else
                log_debug "$package_name already installed"
            fi
            ;;
        "apt")
            if ! dpkg -l "$package_name" &>/dev/null; then
                log_info "Installing $package_name..."
                sudo apt-get install -y "$package_name"
            else
                log_debug "$package_name already installed"
            fi
            ;;
        "pacman")
            if ! pacman -Q "$package_name" &>/dev/null; then
                log_info "Installing $package_name..."
                sudo pacman -S --noconfirm "$package_name" 2>/dev/null || \
                yay -S --noconfirm "$package_name" || \
                log_warn "Failed to install $package_name"
            else
                log_debug "$package_name already installed"
            fi
            ;;
        "dnf")
            if ! rpm -q "$package_name" &>/dev/null; then
                log_info "Installing $package_name..."
                sudo dnf install -y "$package_name"
            else
                log_debug "$package_name already installed"
            fi
            ;;
        *)
            log_error "Unknown package manager: $PACKAGE_MANAGER"
            return 1
            ;;
    esac
}

# Install a cask package (macOS only)
install_cask_package() {
    local cask_name="$1"
    local original_key="$2"
    
    if [[ "$OS_NAME" != "macOS" ]]; then
        log_debug "Cask packages only supported on macOS"
        return 0
    fi
    
    if ! brew list --cask "$cask_name" &>/dev/null; then
        log_info "Installing cask $cask_name..."
        brew install --cask "$cask_name"
    else
        log_debug "Cask $cask_name already installed"
    fi
}

# Create symlink for packages with different names
create_package_symlink() {
    local source_name="$1"
    local target_name="$2"
    
    if command_exists "$source_name" && ! command_exists "$target_name"; then
        log_info "Creating symlink: $source_name -> $target_name"
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(which "$source_name")" "$HOME/.local/bin/$target_name"
        
        # Add ~/.local/bin to PATH if not already there
        if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
            export PATH="$HOME/.local/bin:$PATH"
        fi
    fi
}

# Install packages from essential configuration
install_essential_packages_from_config() {
    local config_file="$PACKAGE_CONFIG_DIR/essential.yaml"
    
    install_packages_from_config "$config_file" "essential" "essential packages"
    install_packages_from_config "$config_file" "shell_enhancements" "shell enhancements"
    install_packages_from_config "$config_file" "completion" "completion tools"
    install_packages_from_config "$config_file" "build_tools" "build tools"
}

# Install packages from development configuration
install_development_packages_from_config() {
    local config_file="$PACKAGE_CONFIG_DIR/development.yaml"
    
    install_packages_from_config "$config_file" "editors" "development editors"
    install_packages_from_config "$config_file" "version_control" "version control tools"
    install_packages_from_config "$config_file" "devops_tools" "DevOps and automation tools"
    install_packages_from_config "$config_file" "build_systems" "build systems"
    install_packages_from_config "$config_file" "development_libraries" "development libraries"
    install_packages_from_config "$config_file" "compilers" "compilers and build tools"
}

# Install packages from fonts configuration
install_fonts_from_config() {
    local config_file="$PACKAGE_CONFIG_DIR/fonts.yaml"
    
    install_packages_from_config "$config_file" "nerd_fonts" "Nerd Fonts"
    install_packages_from_config "$config_file" "system_fonts" "system fonts"
    install_packages_from_config "$config_file" "font_tools" "font utilities"
}

# Install packages from desktop configuration
install_desktop_packages_from_config() {
    local config_file="$PACKAGE_CONFIG_DIR/desktop.yaml"
    
    if [[ "$OS_TYPE" == "Linux" ]]; then
        install_packages_from_config "$config_file" "wayland" "Wayland support"
        install_packages_from_config "$config_file" "window_managers" "window managers"
        install_packages_from_config "$config_file" "desktop_tools" "desktop tools"
        install_packages_from_config "$config_file" "audio" "audio system"
        install_packages_from_config "$config_file" "applications" "desktop applications"
        install_packages_from_config "$config_file" "integration" "desktop integration"
    fi
    
    # Install macOS-specific applications (casks)
    if [[ "$OS_NAME" == "macOS" ]]; then
        install_packages_from_config "$config_file" "macos_apps" "macOS applications"
    fi
}

# Run post-install actions for packages
run_post_install_action() {
    local action="$1"
    local package_name="$2"
    
    log_info "Running post-install action for $package_name: $action"
    
    case "$action" in
        "add_user_to_docker_group")
            add_user_to_docker_group
            ;;
        *)
            log_warn "Unknown post-install action: $action"
            ;;
    esac
}

# Add current user to docker group (Linux only)
add_user_to_docker_group() {
    if [[ "$OS_TYPE" == "Linux" ]]; then
        local current_user=$(whoami)
        
        # Check if docker group exists
        if getent group docker >/dev/null 2>&1; then
            # Check if user is already in docker group
            if ! groups "$current_user" | grep -q "\bdocker\b"; then
                log_info "Adding $current_user to docker group..."
                sudo usermod -aG docker "$current_user"
                log_info "User added to docker group. You may need to log out and back in for changes to take effect."
            else
                log_debug "User $current_user is already in docker group"
            fi
        else
            log_warn "Docker group does not exist. Docker may not be properly installed."
        fi
    else
        log_debug "Docker group management not needed on $OS_TYPE"
    fi
}

# Load custom package configurations
load_custom_packages() {
    local custom_config="$CUSTOM_CONFIG_DIR/packages.yaml"
    
    if [[ -f "$custom_config" ]]; then
        log_info "Loading custom package configuration..."
        # Custom packages can override or extend the default configurations
        # Implementation would depend on specific requirements
    fi
}

# List all available packages
list_available_packages() {
    log_header "Available Package Categories"
    
    echo "Essential Packages:"
    yq eval '.essential | keys | .[]' "$PACKAGE_CONFIG_DIR/essential.yaml" | sed 's/^/  - /'
    
    echo
    echo "Development Packages:"
    yq eval '.editors | keys | .[]' "$PACKAGE_CONFIG_DIR/development.yaml" | sed 's/^/  - /'
    
    echo
    echo "Fonts:"
    yq eval '.nerd_fonts | keys | .[]' "$PACKAGE_CONFIG_DIR/fonts.yaml" | sed 's/^/  - /'
    
    if [[ "$OS_TYPE" == "Linux" ]]; then
        echo
        echo "Desktop Applications:"
        yq eval '.applications | keys | .[]' "$PACKAGE_CONFIG_DIR/desktop.yaml" | sed 's/^/  - /'
    fi
}