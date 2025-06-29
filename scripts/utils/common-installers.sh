#!/bin/bash

# Common installation functions to reduce duplication across platform-specific scripts

# Common development packages installer
install_development_packages() {
    local platform_name="${1:-$(uname -s)}"
    log_step "Installing development packages for $platform_name"

    # Use centralized package configuration
    source "$SCRIPT_DIR/scripts/utils/package-manager.sh"
    init_package_manager
    install_development_packages_from_config

    log_success "Development packages installed successfully"
}

# Common desktop packages installer (for platforms using centralized config)
install_desktop_packages_centralized() {
    local platform_name="${1:-$(uname -s)}"
    log_step "Installing desktop environment packages for $platform_name"

    # Use centralized package configuration
    source "$SCRIPT_DIR/scripts/utils/package-manager.sh"
    init_package_manager
    install_desktop_packages_from_config

    log_success "Desktop environment packages installed successfully"
}

# Common essential packages installer
install_essential_packages_centralized() {
    local platform_name="${1:-$(uname -s)}"
    log_step "Installing essential packages for $platform_name"

    # Use centralized package configuration
    source "$SCRIPT_DIR/scripts/utils/package-manager.sh"
    init_package_manager
    install_essential_packages_from_config

    log_success "Essential packages installed successfully"
}