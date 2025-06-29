#!/bin/bash

# Essential packages for Debian (similar to Ubuntu but may have different package names)

install_essential_packages_for_system() {
    log_step "Installing essential packages for Debian"

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

    # Tailscale repository
    if ! grep -q "tailscale" /etc/apt/sources.list.d/* 2>/dev/null; then
        log_info "Adding Tailscale repository..."
        curl -fsSL https://pkgs.tailscale.com/stable/debian/$(lsb_release -cs).noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
        curl -fsSL https://pkgs.tailscale.com/stable/debian/$(lsb_release -cs).tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
    fi

    # Update after adding repositories
    sudo apt-get update
}

# Note: Additional packages are now installed via centralized YAML configuration
# Package symlinks are handled by the centralized package manager

add_debian_backports() {
    # Check if we need to add backports for newer packages
    if [[ -f /etc/debian_version ]]; then
        local debian_version
        debian_version=$(cat /etc/debian_version | cut -d. -f1)
        if [[ "$debian_version" -lt 11 ]]; then
            log_info "Adding Debian backports for newer packages..."
            echo "deb http://deb.debian.org/debian $(lsb_release -cs)-backports main" | sudo tee /etc/apt/sources.list.d/backports.list
            sudo apt-get update
        fi
    fi
}

# Note: Shell packages are now installed via centralized YAML configuration

# Note: Package symlinks are now handled by the centralized package manager

# Install development tools (using common function)
install_development_packages() {
    source "$SCRIPT_DIR/scripts/utils/common-installers.sh"
    install_development_packages "Debian"
}

# Note: GitHub CLI is now installed via centralized configuration and repository setup

# Install desktop environment packages
install_desktop_packages() {
    log_step "Installing desktop environment packages for Debian"

    local wayland_packages=(
        "wayland-protocols"
        "libwayland-dev"
        "xwayland"
        "kitty"
    )

    local desktop_packages=(
        "firefox-esr"  # Debian typically uses ESR
        "pavucontrol"
        "alsa-utils"
        "vlc"
        "nautilus"
        "playerctl"
        "brightnessctl"
        "python3"
        "python3-pip"
        "python3-venv"
    )

    # Install Wayland packages
    for package in "${wayland_packages[@]}"; do
        if ! dpkg -l "$package" &>/dev/null; then
            log_info "Installing $package..."
            sudo apt-get install -y "$package" || log_warn "Failed to install $package"
        else
            log_debug "$package already installed"
        fi
    done

    # Install desktop packages
    for package in "${desktop_packages[@]}"; do
        if ! dpkg -l "$package" &>/dev/null; then
            log_info "Installing $package..."
            sudo apt-get install -y "$package" || log_warn "Failed to install $package"
        else
            log_debug "$package already installed"
        fi
    done

    # Install Google Chrome
    install_google_chrome

    # Install 1Password
    install_1password

    # Install Obsidian
    install_obsidian

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