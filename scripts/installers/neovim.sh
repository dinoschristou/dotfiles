#!/bin/bash

# Neovim configuration installer

install_neovim_configuration() {
    log_step "Installing Neovim configuration"

    # Ensure Neovim is installed
    ensure_neovim_installed

    # Backup existing Neovim configuration
    backup_existing_neovim_config

    # Deploy Neovim configuration
    deploy_neovim_config

    # Install lazy.nvim package manager
    install_lazy_nvim

    # Initial plugin installation
    install_neovim_plugins

    log_success "Neovim configuration installed successfully"
}

ensure_neovim_installed() {
    if ! command_exists "nvim"; then
        log_info "Neovim not found, installing..."
        case "$OS_NAME" in
            "Darwin")
                brew install neovim
                ;;
            "Ubuntu"|"Debian")
                sudo apt-get install -y neovim
                ;;
            "Arch")
                sudo pacman -S --noconfirm neovim
                ;;
            "Fedora")
                sudo dnf install -y neovim
                ;;
            *)
                log_error "Unknown OS for Neovim installation: $OS_NAME"
                return 1
                ;;
        esac
    else
        log_debug "Neovim already installed"
    fi

    # Verify installation
    if ! command_exists "nvim"; then
        log_error "Failed to install Neovim"
        return 1
    fi

    local nvim_version
    nvim_version=$(nvim --version | head -n1)
    log_info "Neovim version: $nvim_version"
}

backup_existing_neovim_config() {
    log_info "Backing up existing Neovim configuration..."

    local nvim_dirs=(
        "$HOME/.config/nvim"
        "$HOME/.local/share/nvim"
        "$HOME/.local/state/nvim"
        "$HOME/.cache/nvim"
    )

    for dir in "${nvim_dirs[@]}"; do
        if [[ -d "$dir" ]] && [[ ! -L "$dir" ]]; then
            backup_file "$dir"
        fi
    done
}

deploy_neovim_config() {
    log_info "Deploying Neovim configuration..."

    # Create config directory
    mkdir -p "$HOME/.config"

    # Deploy main configuration
    create_symlink "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"

    log_success "Neovim configuration deployed"
}

install_lazy_nvim() {
    log_info "Installing lazy.nvim package manager..."

    local lazy_path="$HOME/.local/share/nvim/lazy/lazy.nvim"
    
    if [[ ! -d "$lazy_path" ]]; then
        log_info "Cloning lazy.nvim..."
        git clone --filter=blob:none --branch=stable \
            https://github.com/folke/lazy.nvim.git "$lazy_path"
        log_success "lazy.nvim installed"
    else
        log_debug "lazy.nvim already installed"
    fi
}

install_neovim_plugins() {
    log_info "Installing Neovim plugins..."

    # Run Neovim headless to install plugins
    if nvim --headless "+Lazy! sync" +qa 2>/dev/null; then
        log_success "Neovim plugins installed successfully"
    else
        log_warn "Plugin installation may have encountered issues"
        log_info "You can run ':Lazy sync' manually in Neovim to complete installation"
    fi

    # Run health check
    run_neovim_health_check
}

run_neovim_health_check() {
    log_info "Running Neovim health check..."

    # Create a temporary file for health check output
    local health_output="/tmp/nvim_health_check.txt"
    
    if nvim --headless -c "checkhealth" -c "wqa" > "$health_output" 2>&1; then
        # Check for any errors in health check
        if grep -qi "error\|warning\|fail" "$health_output"; then
            log_warn "Neovim health check found some issues"
            log_info "Run ':checkhealth' in Neovim to see details"
        else
            log_success "Neovim health check passed"
        fi
    else
        log_warn "Could not run Neovim health check"
    fi

    # Cleanup
    rm -f "$health_output"
}

# Install language servers and tools
install_language_servers() {
    log_info "Installing language servers and development tools..."

    # Install Node.js if not present (needed for many LSP servers)
    ensure_nodejs_installed

    # Install Python support
    ensure_python_support

    # Install common language servers via Mason (if available)
    install_mason_packages

    log_success "Language servers installation completed"
}

ensure_nodejs_installed() {
    if ! command_exists "node"; then
        log_info "Installing Node.js for LSP support..."
        case "$OS_NAME" in
            "Darwin")
                brew install node
                ;;
            "Ubuntu"|"Debian")
                # Install Node.js via NodeSource repository
                curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
                sudo apt-get install -y nodejs
                ;;
            "Arch")
                sudo pacman -S --noconfirm nodejs npm
                ;;
            "Fedora")
                sudo dnf install -y nodejs npm
                ;;
        esac
    else
        log_debug "Node.js already installed"
    fi
}

ensure_python_support() {
    # Install Python provider for Neovim
    if command_exists "pip3"; then
        log_info "Installing Python provider for Neovim..."
        # Handle macOS externally-managed environment
        if [[ "$OS_NAME" == "Darwin" ]]; then
            pip3 install --user --break-system-packages pynvim 2>/dev/null || {
                log_warn "Failed to install pynvim via pip, trying pipx..."
                if command_exists "pipx" || brew install pipx; then
                    pipx install pynvim || log_warn "Failed to install pynvim via pipx"
                fi
            }
        else
            pip3 install --user pynvim
        fi
    elif command_exists "pip"; then
        log_info "Installing Python provider for Neovim..."
        if [[ "$OS_NAME" == "Darwin" ]]; then
            pip install --user --break-system-packages pynvim 2>/dev/null || log_warn "Failed to install pynvim"
        else
            pip install --user pynvim
        fi
    else
        log_warn "pip not found, skipping Python provider installation"
    fi
}

install_mason_packages() {
    log_info "Installing Mason packages..."

    # Common language servers to install
    local mason_packages=(
        "lua-language-server"
        "bash-language-server"
        "typescript-language-server"
        "json-lsp"
        "yaml-language-server"
    )

    # Create Mason install commands
    local mason_install_cmd=""
    for package in "${mason_packages[@]}"; do
        mason_install_cmd="$mason_install_cmd:MasonInstall $package "
    done

    # Run Mason install in headless mode
    if [[ -n "$mason_install_cmd" ]]; then
        log_info "Installing Mason packages: ${mason_packages[*]}"
        nvim --headless -c "lua require('mason').setup()" \
             -c "$mason_install_cmd" \
             -c "qa" 2>/dev/null || log_warn "Mason package installation may have failed"
    fi
}