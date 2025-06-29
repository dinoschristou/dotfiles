#!/bin/bash

# Essential packages for Arch Linux

install_essential_packages_for_system() {
    log_step "Installing essential packages for Arch Linux"

    # Update system
    log_info "Updating system packages..."
    sudo pacman -Syu --noconfirm

    # Install yay AUR helper if not present
    install_yay

    # Initialize package manager and install from config
    source "$SCRIPT_DIR/scripts/utils/package-manager.sh"
    init_package_manager
    
    # Install packages from centralized configuration
    install_essential_packages_from_config
    
    # Install development packages (includes additional tools)
    install_development_packages_from_config

    log_success "Essential packages installed successfully"
}

install_yay() {
    if ! command_exists "yay"; then
        log_info "Installing yay AUR helper..."
        
        # Create temporary directory for yay installation
        local temp_dir="/tmp/yay-install"
        rm -rf "$temp_dir"
        mkdir -p "$temp_dir"
        
        # Clone and install yay
        git clone https://aur.archlinux.org/yay.git "$temp_dir"
        cd "$temp_dir"
        makepkg -si --noconfirm
        cd - > /dev/null
        
        # Cleanup
        rm -rf "$temp_dir"
        
        log_success "yay installed successfully"
    else
        log_debug "yay already installed"
    fi
}

# Note: Shell packages are now installed via centralized YAML configuration

# Install development tools (using common function)
install_development_packages() {
    source "$SCRIPT_DIR/scripts/utils/common-installers.sh"
    install_development_packages "Arch Linux"
}

# Install desktop environment packages
install_desktop_packages() {
    log_step "Installing desktop environment packages for Arch Linux"

    # Wayland packages
    local wayland_packages=(
        "wayland"
        "wayland-protocols"
        "xorg-xwayland"
        "kitty"
    )

    # Hyprland and related packages
    local hyprland_packages=(
        "hyprland"
        "hyprlock"
        "hypridle"
        "waybar"
        "wofi"
        "mako"
        "grim"
        "slurp"
        "wl-clipboard"
        "xdg-desktop-portal-hyprland"
    )

    # Sway packages (alternative)
    local sway_packages=(
        "sway"
        "swaybar"
        "swaylock"
        "swayidle"
        "xdg-desktop-portal-wlr"
    )

    # Audio packages
    local audio_packages=(
        "pipewire"
        "pipewire-pulse"
        "wireplumber"
        "pavucontrol"
        "alsa-utils"
        "playerctl"
    )

    # Desktop applications
    local desktop_packages=(
        "firefox"
        "vlc"
        "nautilus"
        "brightnessctl"
        "python"
        "python-pip"
    )

    # Printer support packages
    local printer_packages=(
        "cups"
        "cups-pdf"
        "ghostscript"
        "gsfonts"
        "gutenprint"
        "gtk3-print-backends"
        "libcups"
        "hplip"
        "system-config-printer"
    )

    # Install Wayland packages
    for package in "${wayland_packages[@]}"; do
        if ! pacman -Q "$package" &>/dev/null; then
            log_info "Installing $package..."
            sudo pacman -S --noconfirm "$package"
        else
            log_debug "$package already installed"
        fi
    done

    # Install Hyprland packages
    for package in "${hyprland_packages[@]}"; do
        if ! pacman -Q "$package" &>/dev/null; then
            log_info "Installing $package..."
            if [[ "$package" == "hyprland" ]] || [[ "$package" == "hyprlock" ]] || [[ "$package" == "hypridle" ]] || [[ "$package" == "wofi" ]]; then
                # These might be in AUR
                yay -S --noconfirm "$package" || sudo pacman -S --noconfirm "$package" 2>/dev/null
            else
                sudo pacman -S --noconfirm "$package"
            fi
        else
            log_debug "$package already installed"
        fi
    done

    # Install Sway packages as fallback
    for package in "${sway_packages[@]}"; do
        if ! pacman -Q "$package" &>/dev/null; then
            log_info "Installing $package..."
            sudo pacman -S --noconfirm "$package"
        else
            log_debug "$package already installed"
        fi
    done

    # Install audio packages
    for package in "${audio_packages[@]}"; do
        if ! pacman -Q "$package" &>/dev/null; then
            log_info "Installing $package..."
            sudo pacman -S --noconfirm "$package"
        else
            log_debug "$package already installed"
        fi
    done

    # Install desktop applications
    for package in "${desktop_packages[@]}"; do
        if ! pacman -Q "$package" &>/dev/null; then
            log_info "Installing $package..."
            sudo pacman -S --noconfirm "$package"
        else
            log_debug "$package already installed"
        fi
    done

    # Install printer support
    install_printer_support

    # Install AUR applications
    install_aur_applications

    log_success "Desktop environment packages installed successfully"
}

install_printer_support() {
    log_info "Installing printer support..."

    local printer_packages=(
        "cups"
        "cups-pdf"
        "ghostscript"
        "gsfonts"
        "gutenprint"
        "gtk3-print-backends"
        "libcups"
        "hplip"
        "system-config-printer"
    )

    for package in "${printer_packages[@]}"; do
        if ! pacman -Q "$package" &>/dev/null; then
            log_info "Installing $package..."
            sudo pacman -S --noconfirm "$package"
        else
            log_debug "$package already installed"
        fi
    done

    # Enable and start CUPS service
    sudo systemctl enable cups.service
    sudo systemctl start cups.service

    log_success "Printer support installed and enabled"
}

install_aur_applications() {
    log_info "Installing AUR applications..."

    local aur_packages=(
        "google-chrome"
        "1password"
        "1password-cli"
        "obsidian"
    )

    for package in "${aur_packages[@]}"; do
        if ! pacman -Q "$package" &>/dev/null; then
            log_info "Installing $package from AUR..."
            yay -S --noconfirm "$package" || log_warn "Failed to install $package from AUR"
        else
            log_debug "$package already installed"
        fi
    done

    log_success "AUR applications installed"
}