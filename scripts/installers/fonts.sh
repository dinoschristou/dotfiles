#!/bin/bash

# Font installer

install_fonts() {
    log_step "Installing fonts"

    # Initialize package manager and install from config
    source "$SCRIPT_DIR/utils/package-manager.sh"
    init_package_manager
    
    # Install fonts from centralized configuration
    install_fonts_from_config

    # Refresh font cache
    refresh_font_cache

    # Verify font installation
    verify_font_installation

    log_success "Fonts installed successfully"
}


install_system_fonts() {
    log_info "Installing system fonts..."

    case "$OS_NAME" in
        "Darwin")
            install_macos_system_fonts
            ;;
        "Ubuntu"|"Debian")
            install_debian_system_fonts
            ;;
        "Arch")
            install_arch_system_fonts
            ;;
        "Fedora")
            install_fedora_system_fonts
            ;;
        *)
            log_warn "Unknown OS for system font installation: $OS_NAME"
            ;;
    esac
}

install_macos_system_fonts() {
    # Install Nerd Fonts via Homebrew casks (these are already included in essential packages)
    log_info "Nerd Fonts are installed via essential packages on macOS"
    
    # Install additional regular fonts
    local font_casks=(
        "font-source-code-pro"
        "font-liberation"
        "font-dejavu"
    )

    for font_cask in "${font_casks[@]}"; do
        if ! brew list --cask "$font_cask" &>/dev/null; then
            log_info "Installing $font_cask..."
            brew install --cask "$font_cask" || log_warn "Failed to install $font_cask"
        else
            log_debug "$font_cask already installed"
        fi
    done
}

install_debian_system_fonts() {
    local font_packages=(
        "fonts-firacode"
        "fonts-hack"
        "fonts-liberation"
        "fonts-dejavu"
        "fonts-noto"
        "fonts-opensans"
    )

    for font_package in "${font_packages[@]}"; do
        if ! dpkg -l "$font_package" &>/dev/null; then
            log_info "Installing $font_package..."
            sudo apt-get install -y "$font_package" || log_warn "Failed to install $font_package"
        else
            log_debug "$font_package already installed"
        fi
    done
}

install_arch_system_fonts() {
    local font_packages=(
        "ttf-firacode-nerd"
        "ttf-hack"
        "ttf-liberation"
        "ttf-dejavu"
        "noto-fonts"
        "ttf-opensans"
    )

    for font_package in "${font_packages[@]}"; do
        if ! pacman -Q "$font_package" &>/dev/null; then
            log_info "Installing $font_package..."
            sudo pacman -S --noconfirm "$font_package" 2>/dev/null || \
            yay -S --noconfirm "$font_package" || \
            log_warn "Failed to install $font_package"
        else
            log_debug "$font_package already installed"
        fi
    done
}

install_fedora_system_fonts() {
    local font_packages=(
        "fira-code-fonts"
        "hack-fonts"
        "liberation-fonts"
        "dejavu-fonts"
        "google-noto-fonts"
        "opensans-fonts"
    )

    for font_package in "${font_packages[@]}"; do
        if ! rpm -q "$font_package" &>/dev/null; then
            log_info "Installing $font_package..."
            sudo dnf install -y "$font_package" || log_warn "Failed to install $font_package"
        else
            log_debug "$font_package already installed"
        fi
    done
}

refresh_font_cache() {
    log_info "Refreshing font cache..."

    case "$OS_NAME" in
        "Darwin")
            # macOS handles font cache automatically
            log_debug "macOS handles font cache automatically"
            ;;
        *)
            # Linux systems
            if command_exists "fc-cache"; then
                fc-cache -fv > /dev/null 2>&1
                log_success "Font cache refreshed"
            else
                log_warn "fc-cache not available, font cache not refreshed"
            fi
            ;;
    esac
}

# Install additional fonts from URLs or files
install_custom_fonts() {
    log_info "Installing custom fonts..."

    # Custom font installations can be added here
    # Example: Install a specific font from a URL
    
    log_debug "Custom font installation placeholder"
}

# Verify font installation
verify_font_installation() {
    log_info "Verifying font installation..."

    local fonts_to_check=(
        "FiraCode"
        "JetBrains"
        "Hack"
    )

    case "$OS_NAME" in
        "Darwin")
            for font in "${fonts_to_check[@]}"; do
                if system_profiler SPFontsDataType | grep -q "$font"; then
                    log_success "$font font family found"
                else
                    log_warn "$font font family not found"
                fi
            done
            ;;
        *)
            # Linux systems
            if command_exists "fc-list"; then
                for font in "${fonts_to_check[@]}"; do
                    if fc-list | grep -qi "$font"; then
                        log_success "$font font family found"
                    else
                        log_warn "$font font family not found"
                    fi
                done
            else
                log_warn "fc-list not available, cannot verify font installation"
            fi
            ;;
    esac
}