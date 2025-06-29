#!/bin/bash

# Essential packages for Fedora

install_essential_packages_for_system() {
    log_step "Installing essential packages for Fedora"

    # Update system
    log_info "Updating system packages..."
    sudo dnf update -y

    # Enable additional repositories
    enable_additional_repos

    # Initialize package manager and install from config
    source "$SCRIPT_DIR/scripts/utils/package-manager.sh"
    init_package_manager
    
    # Install packages from centralized configuration
    install_essential_packages_from_config
    
    # Install development packages (includes additional tools)
    install_development_packages_from_config

    log_success "Essential packages installed successfully"
}

enable_additional_repos() {
    log_info "Enabling additional repositories..."

    # Enable RPM Fusion repositories
    if ! rpm -q rpmfusion-free-release &>/dev/null; then
        log_info "Installing RPM Fusion Free repository..."
        sudo dnf install -y \
            "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
    fi

    if ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
        log_info "Installing RPM Fusion Non-Free repository..."
        sudo dnf install -y \
            "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
    fi

    # Enable COPR repositories for additional packages
    sudo dnf copr enable atim/neovim -y 2>/dev/null || log_debug "Neovim COPR already enabled or failed"
    
    # Add Tailscale repository
    if ! rpm -q tailscale-archive-keyring &>/dev/null; then
        log_info "Adding Tailscale repository..."
        sudo dnf config-manager --add-repo https://pkgs.tailscale.com/stable/fedora/tailscale.repo
    fi
}

# Note: Additional packages are now installed via centralized YAML configuration

# Note: Shell packages are now installed via centralized YAML configuration

# Install development tools (using common function)
install_development_packages() {
    source "$SCRIPT_DIR/scripts/utils/common-installers.sh"
    install_development_packages "Fedora"
}

# Install desktop environment packages
install_desktop_packages() {
    log_step "Installing desktop environment packages for Fedora"

    local wayland_packages=(
        "wayland-devel"
        "wayland-protocols-devel"
        "xorg-x11-server-Xwayland"
        "kitty"
    )

    local sway_packages=(
        "sway"
        "swaylock"
        "swayidle"
        "swaybg"
        "waybar"
        "mako"
        "wofi"
        "grim"
        "slurp"
        "wl-clipboard"
        "xdg-desktop-portal-wlr"
    )

    local desktop_packages=(
        "firefox"
        "pavucontrol"
        "alsa-utils"
    )

    # Install Wayland packages
    for package in "${wayland_packages[@]}"; do
        if ! rpm -q "$package" &>/dev/null; then
            log_info "Installing $package..."
            sudo dnf install -y "$package" || log_warn "Failed to install $package"
        else
            log_debug "$package already installed"
        fi
    done

    # Install Sway ecosystem (Hyprland might need COPR)
    for package in "${sway_packages[@]}"; do
        if ! rpm -q "$package" &>/dev/null; then
            log_info "Installing $package..."
            sudo dnf install -y "$package" || log_warn "Failed to install $package"
        else
            log_debug "$package already installed"
        fi
    done

    # Try to install Hyprland from COPR
    install_hyprland_fedora

    # Additional desktop packages
    local additional_packages=(
        "vlc"
        "nautilus"
        "playerctl"
        "brightnessctl"
        "python3"
        "python3-pip"
    )

    # Install desktop applications
    for package in "${desktop_packages[@]}"; do
        if ! rpm -q "$package" &>/dev/null; then
            log_info "Installing $package..."
            sudo dnf install -y "$package" || log_warn "Failed to install $package"
        else
            log_debug "$package already installed"
        fi
    done

    # Install additional packages
    for package in "${additional_packages[@]}"; do
        if ! rpm -q "$package" &>/dev/null; then
            log_info "Installing $package..."
            sudo dnf install -y "$package" || log_warn "Failed to install $package"
        else
            log_debug "$package already installed"
        fi
    done

    # Install Google Chrome
    install_google_chrome_fedora

    # Install 1Password
    install_1password_fedora

    # Install Obsidian
    install_obsidian_fedora

    log_success "Desktop environment packages installed successfully"
}

install_google_chrome_fedora() {
    if ! command_exists "google-chrome"; then
        log_info "Installing Google Chrome..."
        sudo dnf install -y fedora-workstation-repositories
        sudo dnf config-manager --set-enabled google-chrome
        sudo dnf install -y google-chrome-stable
    else
        log_debug "Google Chrome already installed"
    fi
}

install_1password_fedora() {
    if ! command_exists "1password"; then
        log_info "Installing 1Password..."
        sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
        sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
        sudo dnf install -y 1password 1password-cli
    else
        log_debug "1Password already installed"
    fi
}

install_obsidian_fedora() {
    if ! command_exists "obsidian"; then
        log_info "Installing Obsidian..."
        local obsidian_url="https://github.com/obsidianmd/obsidian-releases/releases/latest/download/obsidian-$(uname -m).rpm"
        sudo dnf install -y "$obsidian_url"
    else
        log_debug "Obsidian already installed"
    fi
}

install_hyprland_fedora() {
    if ! command_exists "hyprland"; then
        log_info "Attempting to install Hyprland from COPR..."
        
        # Enable Hyprland COPR repository
        sudo dnf copr enable solopasha/hyprland -y 2>/dev/null || true
        
        # Try to install Hyprland ecosystem
        local hyprland_packages=(
            "hyprland"
            "hyprland-protocols"
            "hyprlock"
            "hypridle"
        )
        
        local install_success=true
        for pkg in "${hyprland_packages[@]}"; do
            if ! sudo dnf install -y "$pkg" 2>/dev/null; then
                log_warn "Failed to install $pkg"
                install_success=false
            fi
        done
        
        if [[ "$install_success" == "true" ]]; then
            log_success "Hyprland ecosystem installed from COPR"
        else
            log_warn "Some Hyprland packages failed to install, may need manual installation"
            log_info "See: https://hyprland.org/installation/"
        fi
    else
        log_debug "Hyprland already installed"
    fi
}