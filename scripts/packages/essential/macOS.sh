#!/bin/bash

# Essential packages for macOS

install_essential_packages_for_system() {
    log_step "Installing essential packages for macOS"

    # Install Homebrew if not present
    if ! command_exists "brew"; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        log_info "Homebrew already installed"
    fi

    # Update Homebrew
    log_info "Updating Homebrew..."
    brew update

    # Initialize package manager and install from config
    source "$SCRIPT_DIR/scripts/utils/package-manager.sh"
    init_package_manager
    
    # Install packages from centralized configuration
    install_essential_packages_from_config

    log_success "Essential packages installed successfully"
}

# Install development tools
install_development_packages() {
    log_step "Installing development packages for macOS"

    # Use centralized package configuration
    source "$SCRIPT_DIR/scripts/utils/package-manager.sh"
    init_package_manager
    install_development_packages_from_config

    log_success "Development packages installed successfully"
}

# Install desktop applications (casks and fonts)
install_desktop_applications() {
    log_step "Installing desktop applications for macOS"

    # Use centralized package configuration
    source "$SCRIPT_DIR/scripts/utils/package-manager.sh"
    init_package_manager
    
    # Install desktop applications and macOS-specific apps
    install_desktop_packages_from_config
    
    # Install fonts
    install_fonts_from_config

    log_success "Desktop applications installed successfully"
}

# Install additional CLI tools (using common function)
install_additional_cli_tools() {
    source "$SCRIPT_DIR/scripts/utils/common-installers.sh"
    install_development_packages "macOS"
}