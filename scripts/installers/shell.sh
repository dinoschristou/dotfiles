#!/bin/bash

# Shell configuration installer

install_shell_configuration() {
    log_step "Installing shell configuration"

    # Backup existing configurations
    backup_existing_shell_configs

    # Deploy shell configurations
    deploy_zsh_config
    deploy_shell_plugins
    
    # Install Powerlevel10k theme
    install_powerlevel10k

    # Set zsh as default shell if requested
    configure_default_shell
    
    # Install and configure Vim
    install_vim_configuration

    log_success "Shell configuration installed successfully"
}

backup_existing_shell_configs() {
    log_info "Backing up existing shell configurations..."
    
    local configs_to_backup=(
        "$HOME/.zshrc"
        "$HOME/.p10k.zsh"
    )

    for config in "${configs_to_backup[@]}"; do
        if [[ -f "$config" ]] && [[ ! -L "$config" ]]; then
            backup_file "$config"
        fi
    done
}

deploy_zsh_config() {
    log_info "Deploying zsh configuration..."

    # Main zsh configuration
    create_symlink "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
    
    # Powerlevel10k configuration
    create_symlink "$DOTFILES_DIR/p10k.zsh" "$HOME/.p10k.zsh"
    
    # Tmux configuration
    create_symlink "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"
    
    # Lazygit configuration
    mkdir -p "$HOME/.config/lazygit"
    create_symlink "$DOTFILES_DIR/config/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
    
    # Fastfetch configuration
    mkdir -p "$HOME/.config/fastfetch"
    create_symlink "$DOTFILES_DIR/config/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
    
    # Sway wallpaper script (Linux only)
    if [[ "$OS_TYPE" == "Linux" ]]; then
        mkdir -p "$HOME/.config/sway"
        create_symlink "$DOTFILES_DIR/config/sway/wallpaper.sh" "$HOME/.config/sway/wallpaper.sh"
        
        # MIME type associations
        create_symlink "$DOTFILES_DIR/config/mimeapps.list" "$HOME/.config/mimeapps.list"
    fi
    
    # Setup XDG user data directories
    setup_local_share_data

    # Ensure zsh is installed
    if ! command_exists "zsh"; then
        log_error "zsh is not installed. Please install it first."
        return 1
    fi

    log_success "zsh configuration deployed"
}


deploy_shell_plugins() {
    log_info "Setting up shell plugins..."

    case "$OS_NAME" in
        "Darwin")
            setup_macos_shell_plugins
            ;;
        "Ubuntu"|"Debian")
            setup_debian_shell_plugins
            ;;
        "Arch")
            setup_arch_shell_plugins
            ;;
        "Fedora")
            setup_fedora_shell_plugins
            ;;
        *)
            log_warn "Unknown OS for shell plugin setup: $OS_NAME"
            ;;
    esac
}

setup_macos_shell_plugins() {
    # Plugins are installed via Homebrew, just need to source them
    log_info "macOS shell plugins configured via Homebrew"
}

setup_debian_shell_plugins() {
    # Create .local/bin directory for user binaries
    mkdir -p "$HOME/.local/bin"
    
    # Ensure .local/bin is in PATH
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        log_info "Adding ~/.local/bin to PATH"
    fi
}

setup_arch_shell_plugins() {
    # Plugins installed via pacman/yay
    log_info "Arch shell plugins configured via package manager"
}

setup_fedora_shell_plugins() {
    # Similar to Debian/Ubuntu
    mkdir -p "$HOME/.local/bin"
}

configure_default_shell() {
    if [[ "$CURRENT_SHELL" != "zsh" ]] && command_exists "zsh"; then
        if [[ "$INTERACTIVE_MODE" == true ]]; then
            if ask_yes_no "Set zsh as your default shell?" "y"; then
                set_default_shell_to_zsh
            fi
        else
            log_info "Skipping default shell change in non-interactive mode"
        fi
    else
        log_debug "zsh is already the default shell or not available"
    fi
}

set_default_shell_to_zsh() {
    local zsh_path
    zsh_path=$(which zsh)
    
    if [[ -z "$zsh_path" ]]; then
        log_error "zsh not found in PATH"
        return 1
    fi

    # Add zsh to /etc/shells if not already there
    if ! grep -q "$zsh_path" /etc/shells 2>/dev/null; then
        log_info "Adding zsh to /etc/shells..."
        echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null
    fi

    # Change default shell
    log_info "Changing default shell to zsh..."
    if chsh -s "$zsh_path"; then
        log_success "Default shell changed to zsh"
        log_info "Please log out and log back in for the change to take effect"
    else
        log_error "Failed to change default shell"
        return 1
    fi
}

# Install additional shell tools
install_shell_tools() {
    log_info "Installing additional shell tools..."

    # Install fzf key bindings and completion
    setup_fzf_integration

    # Install any additional tools
    install_additional_tools
}

setup_fzf_integration() {
    if command_exists "fzf"; then
        log_info "Setting up fzf integration..."
        
        case "$OS_NAME" in
            "Darwin")
                # On macOS with Homebrew, fzf integration is handled in zshrc
                log_debug "fzf integration handled via Homebrew"
                ;;
            *)
                # On Linux, may need to run fzf install script
                if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
                    log_debug "fzf key bindings available via package"
                else
                    log_info "Installing fzf key bindings..."
                    if command_exists "fzf" && [[ -x "$(command -v fzf)" ]]; then
                        # Run fzf install if available
                        "$(dirname "$(which fzf)")/../share/fzf/install" --key-bindings --completion --no-update-rc 2>/dev/null || true
                    fi
                fi
                ;;
        esac
    else
        log_warn "fzf not found, skipping integration setup"
    fi
}

install_additional_tools() {
    # Any additional shell tools that need special installation
    log_debug "Additional shell tools setup complete"
}

# Install and configure Vim with Vundle
install_vim_configuration() {
    log_step "Installing Vim configuration..."
    
    # Ensure vim is installed
    if ! command_exists "vim"; then
        log_warn "Vim is not installed. It will be installed with the essential packages."
    fi
    
    # Backup existing vimrc
    if [[ -f "$HOME/.vimrc" ]] && [[ ! -L "$HOME/.vimrc" ]]; then
        backup_file "$HOME/.vimrc"
    fi
    
    # Link vimrc
    create_symlink "$DOTFILES_DIR/vimrc" "$HOME/.vimrc"
    log_success "Linked .vimrc"
    
    # Install Vundle if not present
    install_vundle
    
    # Install Vim plugins
    install_vim_plugins
    
    log_success "Vim configuration installed"
}

# Install Vundle plugin manager
install_vundle() {
    local vundle_dir="$HOME/.vim/bundle/Vundle.vim"
    
    if [[ ! -d "$vundle_dir" ]]; then
        log_info "Installing Vundle plugin manager..."
        
        # Create .vim directory structure
        mkdir -p "$HOME/.vim/bundle"
        
        # Clone Vundle
        if git clone https://github.com/VundleVim/Vundle.vim.git "$vundle_dir"; then
            log_success "Vundle installed successfully"
        else
            log_error "Failed to install Vundle"
            return 1
        fi
    else
        log_debug "Vundle already installed"
        
        # Update Vundle
        log_info "Updating Vundle..."
        cd "$vundle_dir" && git pull origin master
    fi
}

# Install Vim plugins via Vundle
install_vim_plugins() {
    if command_exists "vim" && [[ -f "$HOME/.vimrc" ]]; then
        log_info "Installing Vim plugins..."
        
        # Install plugins non-interactively
        vim +PluginInstall +qall &>/dev/null || {
            log_warn "Plugin installation may have failed or completed with warnings"
            log_info "You can run ':PluginInstall' manually in Vim to retry"
        }
        
        log_success "Vim plugins installation completed"
    else
        log_warn "Vim or .vimrc not available, skipping plugin installation"
    fi
}

# Install Powerlevel10k theme from GitHub
install_powerlevel10k() {
    log_step "Installing Powerlevel10k theme..."
    
    local p10k_dir="$HOME/powerlevel10k"
    
    # Check if Powerlevel10k is already installed
    if [[ -d "$p10k_dir" ]]; then
        log_info "Powerlevel10k already installed, updating..."
        
        # Update existing installation
        cd "$p10k_dir" && git pull origin master
        if [[ $? -eq 0 ]]; then
            log_success "Powerlevel10k updated successfully"
        else
            log_warn "Failed to update Powerlevel10k, but existing installation should still work"
        fi
    else
        log_info "Cloning Powerlevel10k from GitHub..."
        
        # Clone Powerlevel10k repository
        if git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"; then
            log_success "Powerlevel10k installed successfully"
        else
            log_error "Failed to install Powerlevel10k"
            return 1
        fi
    fi
    
    # Verify installation
    if [[ -f "$p10k_dir/powerlevel10k.zsh-theme" ]]; then
        log_success "Powerlevel10k theme file verified"
        
        # Check if we have a p10k config file in dotfiles
        if [[ -f "$DOTFILES_DIR/p10k.zsh" ]]; then
            log_info "Powerlevel10k configuration found in dotfiles"
        else
            log_info "No p10k configuration found. You can run 'p10k configure' to set up the theme"
        fi
    else
        log_error "Powerlevel10k installation verification failed"
        return 1
    fi
    
    # Update prompt configuration to use correct path
    update_prompt_config_path
}

# Setup ~/.local/share data directories and files
setup_local_share_data() {
    log_info "Setting up XDG user data directories..."
    
    # Run the local share setup script
    if [[ -f "$DOTFILES_DIR/scripts/setup-local-share.sh" ]]; then
        source "$DOTFILES_DIR/scripts/setup-local-share.sh"
        setup_local_share
    else
        log_warn "Local share setup script not found, creating basic directories..."
        
        # Create basic XDG directories
        local xdg_data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
        mkdir -p "$xdg_data_home"/{applications,icons,themes,wallpapers,fonts}
        
        log_info "Basic XDG directories created"
    fi
}

# Update the prompt configuration to use the installed Powerlevel10k path
update_prompt_config_path() {
    local prompt_config="$XDG_CONFIG_HOME/zsh/prompt.zsh"
    
    if [[ -f "$prompt_config" ]]; then
        log_info "Updating Powerlevel10k path in prompt configuration..."
        
        # Use a more robust path that works across platforms
        local p10k_theme_path="$HOME/powerlevel10k/powerlevel10k.zsh-theme"
        
        # Update the prompt.zsh file to use the correct path
        sed -i.bak "s|~/powerlevel10k/powerlevel10k.zsh-theme|$p10k_theme_path|g" "$prompt_config"
        
        # Remove backup file
        rm -f "$prompt_config.bak"
        
        log_success "Prompt configuration updated"
    else
        log_warn "Prompt configuration file not found at $prompt_config"
    fi
}