#!/bin/bash

# Desktop environment installer (Linux only)

install_desktop_environment() {
    if [[ "$OS_TYPE" != "Linux" ]]; then
        log_error "Desktop environment installation is only supported on Linux"
        return 1
    fi

    log_step "Installing desktop environment for Linux"

    # Install Wayland/X11 dependencies
    install_display_server_deps

    # Install window managers
    install_window_managers

    # Install supporting applications
    install_desktop_applications

    # Deploy desktop configurations
    deploy_desktop_configs

    # Install audio system
    install_audio_system

    # Install themes and icons
    install_themes_and_icons

    log_success "Desktop environment installed successfully"
}

install_display_server_deps() {
    log_info "Installing display server dependencies..."

    case "$OS_NAME" in
        "Ubuntu"|"Debian")
            install_debian_display_deps
            ;;
        "Arch")
            install_arch_display_deps
            ;;
        "Fedora")
            install_fedora_display_deps
            ;;
        *)
            log_error "Unsupported distribution for desktop installation: $OS_NAME"
            return 1
            ;;
    esac
}

install_debian_display_deps() {
    local wayland_deps=(
        "wayland-protocols"
        "libwayland-dev"
        "libwayland-client0"
        "libwayland-server0"
        "xwayland"
        "libxkbcommon-dev"
        "libinput-dev"
        "libdrm-dev"
        "libxcb-composite0-dev"
        "libxcb-xfixes0-dev"
        "libxcb-image0-dev"
        "libxcb-render-util0-dev"
        "libxcb-ewmh-dev"
    )

    for package in "${wayland_deps[@]}"; do
        if ! dpkg -l "$package" &>/dev/null; then
            log_info "Installing $package..."
            sudo apt-get install -y "$package" || log_warn "Failed to install $package"
        fi
    done
}

install_arch_display_deps() {
    local wayland_deps=(
        "wayland"
        "wayland-protocols"
        "xorg-xwayland"
        "libxkbcommon"
        "libinput"
        "libdrm"
        "xcb-util-wm"
        "xcb-util-image"
        "xcb-util-renderutil"
    )

    for package in "${wayland_deps[@]}"; do
        if ! pacman -Q "$package" &>/dev/null; then
            log_info "Installing $package..."
            sudo pacman -S --noconfirm "$package" || log_warn "Failed to install $package"
        fi
    done
}

install_fedora_display_deps() {
    local wayland_deps=(
        "wayland-devel"
        "wayland-protocols-devel"
        "xorg-x11-server-Xwayland"
        "libxkbcommon-devel"
        "libinput-devel"
        "libdrm-devel"
        "xcb-util-wm-devel"
        "xcb-util-image-devel"
        "xcb-util-renderutil-devel"
    )

    for package in "${wayland_deps[@]}"; do
        if ! rpm -q "$package" &>/dev/null; then
            log_info "Installing $package..."
            sudo dnf install -y "$package" || log_warn "Failed to install $package"
        fi
    done
}

install_window_managers() {
    log_info "Installing window managers..."

    # Install Hyprland (primary)
    install_hyprland

    # Install Sway (fallback)
    install_sway

    # Install supporting tools
    install_wm_tools
}

install_hyprland() {
    log_info "Installing Hyprland..."

    case "$OS_NAME" in
        "Ubuntu"|"Debian")
            # Hyprland may need to be built from source or installed from PPA
            install_hyprland_debian
            ;;
        "Arch")
            # Install from official repos or AUR
            if ! pacman -Q "hyprland" &>/dev/null; then
                sudo pacman -S --noconfirm hyprland || yay -S --noconfirm hyprland
            fi
            ;;
        "Fedora")
            # Install from COPR or build from source
            install_hyprland_fedora
            ;;
    esac
}

install_hyprland_debian() {
    # For Ubuntu/Debian, we might need to build from source or use a PPA
    if ! command_exists "hyprland"; then
        log_info "Installing Hyprland build dependencies..."
        sudo apt-get install -y \
            meson ninja-build cmake \
            libwlroots-dev libxcb-dri3-dev \
            libxcb-present-dev libxcb-composite0-dev \
            libxcb-render0-dev libx11-xcb-dev

        # Check for available packages or suggest manual installation
        log_warn "Hyprland may need to be installed manually on $OS_NAME"
        log_info "Consider building from source: https://github.com/hyprwm/Hyprland"
    fi
}

install_hyprland_fedora() {
    # Try to install from COPR
    if ! command_exists "hyprland"; then
        log_info "Attempting to install Hyprland from COPR..."
        sudo dnf copr enable solopasha/hyprland -y 2>/dev/null || true
        sudo dnf install -y hyprland || log_warn "Hyprland installation failed, may need manual installation"
    fi
}

install_sway() {
    log_info "Installing Sway..."

    case "$OS_NAME" in
        "Ubuntu"|"Debian")
            local sway_packages=(
                "sway"
                "swaybar"
                "swaylock"
                "swayidle"
                "swaybg"
                "xdg-desktop-portal-wlr"
            )
            ;;
        "Arch")
            local sway_packages=(
                "sway"
                "swaylock"
                "swayidle"
                "swaybg"
                "xdg-desktop-portal-wlr"
            )
            ;;
        "Fedora")
            local sway_packages=(
                "sway"
                "swaylock"
                "swayidle"
                "swaybg"
                "xdg-desktop-portal-wlr"
            )
            ;;
    esac

    for package in "${sway_packages[@]}"; do
        install_package_if_missing "$package" "$OS_NAME"
    done
}

install_wm_tools() {
    log_info "Installing window manager supporting tools..."

    # Screen capture tools
    local screen_tools=(
        "grim"      # Screenshot utility
        "slurp"     # Screen area selection
        "wl-clipboard"  # Clipboard utilities
    )

    # Status bar and launcher
    local ui_tools=(
        "waybar"    # Status bar
        "mako"      # Notification daemon
    )

    # Install screen tools
    for tool in "${screen_tools[@]}"; do
        install_package_if_missing "$tool" "$OS_NAME"
    done

    # Install UI tools
    for tool in "${ui_tools[@]}"; do
        install_package_if_missing "$tool" "$OS_NAME"
    done

    # Install wofi for Wayland
    install_wofi
}

install_wofi() {
    # Wofi is available in most repositories
    install_package_if_missing "wofi" "$OS_NAME"
}

install_desktop_applications() {
    log_info "Installing desktop applications..."

    # Terminal emulator
    install_package_if_missing "kitty" "$OS_NAME"

    # Web browser
    install_package_if_missing "firefox" "$OS_NAME"

    # File manager
    case "$OS_NAME" in
        "Ubuntu"|"Debian")
            install_package_if_missing "thunar" "$OS_NAME"
            ;;
        "Arch")
            install_package_if_missing "thunar" "$OS_NAME"
            ;;
        "Fedora")
            install_package_if_missing "thunar" "$OS_NAME"
            ;;
    esac

    # Additional applications
    install_media_applications
}

install_media_applications() {
    log_info "Installing media applications..."

    local media_apps=(
        "mpv"       # Video player
        "imv"       # Image viewer
    )

    for app in "${media_apps[@]}"; do
        install_package_if_missing "$app" "$OS_NAME"
    done
}

deploy_desktop_configs() {
    log_info "Deploying desktop configurations..."

    # Create config directories
    mkdir -p "$HOME/.config"

    # Deploy Hyprland configuration
    if [[ -d "$DOTFILES_DIR/config/hypr" ]]; then
        create_symlink "$DOTFILES_DIR/config/hypr" "$HOME/.config/hypr"
        log_success "Hyprland configuration deployed"
    fi

    # Deploy Sway configuration
    if [[ -d "$DOTFILES_DIR/config/sway" ]]; then
        create_symlink "$DOTFILES_DIR/config/sway" "$HOME/.config/sway"
        log_success "Sway configuration deployed"
    fi

    # Deploy Waybar configuration
    if [[ -d "$DOTFILES_DIR/config/waybar" ]]; then
        create_symlink "$DOTFILES_DIR/config/waybar" "$HOME/.config/waybar"
        log_success "Waybar configuration deployed"
    fi

    # Deploy Wofi configuration
    if [[ -d "$DOTFILES_DIR/config/wofi" ]]; then
        create_symlink "$DOTFILES_DIR/config/wofi" "$HOME/.config/wofi"
        log_success "Wofi configuration deployed"
    fi

    # Deploy Mako configuration
    if [[ -d "$DOTFILES_DIR/config/mako" ]]; then
        create_symlink "$DOTFILES_DIR/config/mako" "$HOME/.config/mako"
        log_success "Mako configuration deployed"
    fi

    # Deploy Kitty configuration
    if [[ -d "$DOTFILES_DIR/config/kitty" ]]; then
        create_symlink "$DOTFILES_DIR/config/kitty" "$HOME/.config/kitty"
        log_success "Kitty configuration deployed"
    fi

    # Deploy btop configuration
    if [[ -d "$DOTFILES_DIR/config/btop" ]]; then
        create_symlink "$DOTFILES_DIR/config/btop" "$HOME/.config/btop"
        log_success "btop configuration deployed"
    fi
}

install_audio_system() {
    log_info "Installing audio system..."

    case "$OS_NAME" in
        "Ubuntu"|"Debian")
            install_debian_audio
            ;;
        "Arch")
            install_arch_audio
            ;;
        "Fedora")
            install_fedora_audio
            ;;
    esac
}

install_debian_audio() {
    local audio_packages=(
        "pipewire"
        "pipewire-pulse"
        "wireplumber"
        "pavucontrol"
        "alsa-utils"
    )

    for package in "${audio_packages[@]}"; do
        install_package_if_missing "$package" "$OS_NAME"
    done

    # Enable pipewire services
    systemctl --user enable pipewire pipewire-pulse wireplumber 2>/dev/null || true
}

install_arch_audio() {
    local audio_packages=(
        "pipewire"
        "pipewire-pulse"
        "wireplumber"
        "pavucontrol"
        "alsa-utils"
    )

    for package in "${audio_packages[@]}"; do
        install_package_if_missing "$package" "$OS_NAME"
    done

    # Enable pipewire services
    systemctl --user enable pipewire pipewire-pulse wireplumber 2>/dev/null || true
}

install_fedora_audio() {
    local audio_packages=(
        "pipewire"
        "pipewire-pulseaudio"
        "wireplumber"
        "pavucontrol"
        "alsa-utils"
    )

    for package in "${audio_packages[@]}"; do
        install_package_if_missing "$package" "$OS_NAME"
    done

    # Enable pipewire services
    systemctl --user enable pipewire pipewire-pulse wireplumber 2>/dev/null || true
}

install_themes_and_icons() {
    log_info "Installing themes and icons..."

    case "$OS_NAME" in
        "Ubuntu"|"Debian")
            local theme_packages=(
                "papirus-icon-theme"
                "arc-theme"
                "gtk2-engines-murrine"
            )
            ;;
        "Arch")
            local theme_packages=(
                "papirus-icon-theme"
                "arc-gtk-theme"
                "gtk-engine-murrine"
            )
            ;;
        "Fedora")
            local theme_packages=(
                "papirus-icon-theme"
                "arc-theme"
                "gtk-murrine-engine"
            )
            ;;
    esac

    for package in "${theme_packages[@]}"; do
        install_package_if_missing "$package" "$OS_NAME" || log_warn "Failed to install theme package: $package"
    done
}