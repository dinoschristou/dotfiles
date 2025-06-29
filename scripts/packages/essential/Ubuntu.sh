#!/bin/bash

# Essential packages for Ubuntu

install_essential_packages_for_system() {
    log_step "Installing essential packages for Ubuntu"

    # Update package lists
    log_info "Updating package lists..."
    sudo apt-get update

    # Add additional repositories first
    add_repositories

    # Initialize package manager and install from config
    source "$SCRIPT_DIR/scripts/utils/package-manager.sh"
    init_package_manager
    
    # Install packages from centralized configuration
    install_essential_packages_from_config
    
    # Install development packages (includes additional tools)
    install_development_packages_from_config

    log_success "Essential packages installed successfully"
}

add_repositories() {
    log_info "Adding additional repositories..."

    local needs_update=false

    # Neovim stable PPA
    if ! grep -r "neovim-ppa/stable" /etc/apt/sources.list.d/ /etc/apt/sources.list 2>/dev/null | grep -q -v "^#"; then
        log_info "Adding Neovim stable PPA..."
        sudo add-apt-repository -y ppa:neovim-ppa/stable
        needs_update=true
    else
        log_debug "Neovim PPA already configured"
    fi

    # Tailscale repository
    if ! grep -r "pkgs.tailscale.com" /etc/apt/sources.list.d/ /etc/apt/sources.list 2>/dev/null | grep -q -v "^#"; then
        log_info "Adding Tailscale repository..."
        curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/$(lsb_release -cs).noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
        curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/$(lsb_release -cs).tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
        needs_update=true
    else
        log_debug "Tailscale repository already configured"
    fi

    # GitHub CLI repository
    if ! grep -r "cli.github.com/packages" /etc/apt/sources.list.d/ /etc/apt/sources.list 2>/dev/null | grep -q -v "^#"; then
        log_info "Adding GitHub CLI repository..."
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /usr/share/keyrings/githubcli-archive-keyring.gpg > /dev/null
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        needs_update=true
    else
        log_debug "GitHub CLI repository already configured"
    fi

    # Only update if repositories were added
    if [[ "$needs_update" == true ]]; then
        log_info "Updating package lists after adding repositories..."
        sudo apt-get update
    else
        log_debug "No new repositories added, skipping update"
    fi
}

# Note: Additional packages are now installed via centralized YAML configuration
# Symlinks for packages with different names are handled by the package manager

# Note: Shell packages are now installed via centralized YAML configuration

# Note: Package symlinks are now handled by the centralized package manager

# Install development tools (using common function)
install_development_packages() {
    source "$SCRIPT_DIR/utils/common-installers.sh"
    install_development_packages "Ubuntu"
}

# Note: GitHub CLI is now installed via centralized configuration and repository setup

# Install desktop environment packages
install_desktop_packages() {
    log_step "Installing desktop environment packages for Ubuntu"

    # Use centralized package configuration
    source "$SCRIPT_DIR/scripts/utils/package-manager.sh"
    init_package_manager
    install_desktop_packages_from_config

    # Install third-party applications that require manual setup
    install_google_chrome
    install_1password
    install_obsidian
    install_typora

    log_success "Desktop environment packages installed successfully"
}

install_google_chrome() {
    if ! command_exists "google-chrome"; then
        log_info "Installing Google Chrome..."
        wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
        echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
        sudo apt-get update
        sudo apt-get install -y google-chrome-stable
    else
        log_debug "Google Chrome already installed"
    fi
}

install_1password() {
    if ! command_exists "1password" && ! dpkg -l "1password" &>/dev/null; then
        log_info "Installing 1Password..."
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | sudo tee /etc/apt/sources.list.d/1password.list
        sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
        curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
        sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
        sudo apt-get update
        sudo apt-get install -y 1password 1password-cli
    else
        log_debug "1Password already installed"
    fi
}

install_obsidian() {
    if ! command_exists "obsidian"; then
        log_info "Installing Obsidian..."
        local obsidian_url="https://github.com/obsidianmd/obsidian-releases/releases/latest/download/obsidian_$(dpkg --print-architecture).deb"
        wget -O /tmp/obsidian.deb "$obsidian_url"
        sudo dpkg -i /tmp/obsidian.deb || sudo apt-get install -f -y
        rm -f /tmp/obsidian.deb
    else
        log_debug "Obsidian already installed"
    fi
}

install_typora() {
    if ! command_exists "typora"; then
        log_info "Installing Typora..."
        
        # Add Typora repository key
        wget -qO - https://typora.io/linux/public-key.asc | sudo tee /etc/apt/trusted.gpg.d/typora.asc
        
        # Add Typora repository
        echo 'deb https://typora.io/linux ./' | sudo tee /etc/apt/sources.list.d/typora.list
        
        # Update and install
        sudo apt-get update
        sudo apt-get install -y typora
    else
        log_debug "Typora already installed"
    fi
}