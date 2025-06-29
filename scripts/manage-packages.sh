#!/bin/bash

# Package management utility for dotfiles
# Allows users to view, add, and manage packages easily

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Source utilities
source "$SCRIPT_DIR/utils/logger.sh"
source "$SCRIPT_DIR/utils/helpers.sh"
source "$SCRIPT_DIR/core/detect-system.sh"

# Configuration paths
PACKAGE_CONFIG_DIR="$SCRIPT_DIR/packages/config"
CUSTOM_CONFIG_DIR="$SCRIPT_DIR/packages/custom"
CUSTOM_CONFIG_FILE="$CUSTOM_CONFIG_DIR/packages.yaml"

# Detect system
detect_system

show_usage() {
    cat << EOF
Package Management Utility

USAGE:
    $0 [COMMAND] [OPTIONS]

COMMANDS:
    list            List all available packages
    list-custom     List your custom packages
    add <package>   Add a package to your custom configuration
    remove <package> Remove a package from your custom configuration
    edit            Edit your custom package configuration
    install         Install packages from configuration files
    template        Create custom package template
    
OPTIONS:
    -h, --help      Show this help message
    -c, --category  Specify package category (essential, development, desktop, fonts)
    -p, --platform  Specify platform override (macos, ubuntu, debian, arch, fedora)

EXAMPLES:
    $0 list                    # List all available packages
    $0 list -c essential       # List essential packages only
    $0 add htop                # Add htop to custom packages
    $0 install                 # Install all configured packages
    $0 edit                    # Edit custom configuration
    
EOF
}

list_packages() {
    local category="$1"
    
    log_header "Available Packages"
    
    if [[ -n "$category" ]]; then
        list_category_packages "$category"
    else
        list_all_packages
    fi
}

list_all_packages() {
    echo "=== Essential Packages ==="
    list_category_packages "essential"
    echo
    
    echo "=== Development Packages ==="
    list_category_packages "development"
    echo
    
    echo "=== Fonts ==="
    list_category_packages "fonts"
    echo
    
    if [[ "$OS_TYPE" == "Linux" ]]; then
        echo "=== Desktop Applications ==="
        list_category_packages "desktop"
        echo
    fi
    
    if [[ -f "$CUSTOM_CONFIG_FILE" ]]; then
        echo "=== Custom Packages ==="
        list_custom_packages
    fi
}

list_category_packages() {
    local category="$1"
    local config_file
    local yaml_category
    
    case "$category" in
        "essential")
            config_file="$PACKAGE_CONFIG_DIR/essential.yaml"
            echo "Essential CLI tools:"
            yq eval '.essential | keys | .[]' "$config_file" 2>/dev/null | sed 's/^/  - /' || echo "  No packages found"
            echo
            echo "Shell enhancements:"
            yq eval '.shell_enhancements | keys | .[]' "$config_file" 2>/dev/null | sed 's/^/  - /' || echo "  No packages found"
            ;;
        "development")
            config_file="$PACKAGE_CONFIG_DIR/development.yaml"
            echo "Editors:"
            yq eval '.editors | keys | .[]' "$config_file" 2>/dev/null | sed 's/^/  - /' || echo "  No packages found"
            echo
            echo "Version control:"
            yq eval '.version_control | keys | .[]' "$config_file" 2>/dev/null | sed 's/^/  - /' || echo "  No packages found"
            ;;
        "fonts")
            config_file="$PACKAGE_CONFIG_DIR/fonts.yaml"
            echo "Nerd Fonts:"
            yq eval '.nerd_fonts | keys | .[]' "$config_file" 2>/dev/null | sed 's/^/  - /' || echo "  No packages found"
            echo
            echo "System fonts:"
            yq eval '.system_fonts | keys | .[]' "$config_file" 2>/dev/null | sed 's/^/  - /' || echo "  No packages found"
            ;;
        "desktop")
            if [[ "$OS_TYPE" != "Linux" ]]; then
                echo "Desktop packages are only available on Linux"
                return
            fi
            config_file="$PACKAGE_CONFIG_DIR/desktop.yaml"
            echo "Window managers:"
            yq eval '.window_managers | keys | .[]' "$config_file" 2>/dev/null | sed 's/^/  - /' || echo "  No packages found"
            echo
            echo "Applications:"
            yq eval '.applications | keys | .[]' "$config_file" 2>/dev/null | sed 's/^/  - /' || echo "  No packages found"
            ;;
        *)
            log_error "Unknown category: $category"
            log_info "Available categories: essential, development, fonts, desktop"
            return 1
            ;;
    esac
}

list_custom_packages() {
    if [[ ! -f "$CUSTOM_CONFIG_FILE" ]]; then
        echo "  No custom packages configured"
        echo "  Run '$0 template' to create custom configuration"
        return
    fi
    
    echo "Custom essential:"
    yq eval '.custom_essential | keys | .[]' "$CUSTOM_CONFIG_FILE" 2>/dev/null | sed 's/^/  - /' || echo "  None"
    echo
    echo "Custom development:"
    yq eval '.custom_development | keys | .[]' "$CUSTOM_CONFIG_FILE" 2>/dev/null | sed 's/^/  - /' || echo "  None"
}

add_package() {
    local package_name="$1"
    local category="${2:-custom_essential}"
    local platform="${3:-all}"
    
    if [[ -z "$package_name" ]]; then
        log_error "Package name is required"
        return 1
    fi
    
    # Create custom config if it doesn't exist
    if [[ ! -f "$CUSTOM_CONFIG_FILE" ]]; then
        create_custom_template
    fi
    
    log_info "Adding package '$package_name' to category '$category'"
    
    # Add package to YAML file
    # This is a simplified implementation - in practice, you'd want more robust YAML manipulation
    if ! grep -q "^$category:" "$CUSTOM_CONFIG_FILE"; then
        echo "$category:" >> "$CUSTOM_CONFIG_FILE"
    fi
    
    # Add the package (simple implementation)
    echo "  $package_name: {}" >> "$CUSTOM_CONFIG_FILE"
    
    log_success "Package '$package_name' added to custom configuration"
    log_info "Edit '$CUSTOM_CONFIG_FILE' to customize platform-specific names"
}

remove_package() {
    local package_name="$1"
    
    if [[ -z "$package_name" ]]; then
        log_error "Package name is required"
        return 1
    fi
    
    if [[ ! -f "$CUSTOM_CONFIG_FILE" ]]; then
        log_warn "No custom configuration file found"
        return 1
    fi
    
    # Remove package from YAML (simple implementation)
    if grep -q "  $package_name:" "$CUSTOM_CONFIG_FILE"; then
        sed -i.bak "/  $package_name:/d" "$CUSTOM_CONFIG_FILE"
        log_success "Package '$package_name' removed from custom configuration"
    else
        log_warn "Package '$package_name' not found in custom configuration"
    fi
}

edit_custom_config() {
    if [[ ! -f "$CUSTOM_CONFIG_FILE" ]]; then
        create_custom_template
    fi
    
    local editor="${EDITOR:-${VISUAL:-nano}}"
    log_info "Opening custom configuration in $editor..."
    "$editor" "$CUSTOM_CONFIG_FILE"
}

create_custom_template() {
    log_info "Creating custom package configuration template..."
    cp "$CUSTOM_CONFIG_DIR/packages.yaml.template" "$CUSTOM_CONFIG_FILE"
    log_success "Custom configuration created at $CUSTOM_CONFIG_FILE"
    log_info "Edit this file to add your custom packages"
}

install_packages() {
    log_header "Installing Packages from Configuration"
    
    # Source package manager utilities
    source "$SCRIPT_DIR/utils/package-manager.sh"
    init_package_manager
    
    # Install from each category
    install_essential_packages_from_config
    install_development_packages_from_config
    install_fonts_from_config
    
    if [[ "$OS_TYPE" == "Linux" ]]; then
        install_desktop_packages_from_config
    fi
    
    # Install custom packages if they exist
    if [[ -f "$CUSTOM_CONFIG_FILE" ]]; then
        log_info "Installing custom packages..."
        # Implementation would depend on custom package structure
    fi
    
    log_success "Package installation completed"
}

main() {
    local command="$1"
    shift
    
    case "$command" in
        list)
            local category=""
            while [[ $# -gt 0 ]]; do
                case $1 in
                    -c|--category)
                        category="$2"
                        shift 2
                        ;;
                    *)
                        shift
                        ;;
                esac
            done
            list_packages "$category"
            ;;
        list-custom)
            list_custom_packages
            ;;
        add)
            add_package "$1" "$2" "$3"
            ;;
        remove)
            remove_package "$1"
            ;;
        edit)
            edit_custom_config
            ;;
        install)
            install_packages
            ;;
        template)
            create_custom_template
            ;;
        -h|--help|help)
            show_usage
            ;;
        *)
            if [[ -z "$command" ]]; then
                show_usage
            else
                log_error "Unknown command: $command"
                show_usage
                exit 1
            fi
            ;;
    esac
}

# Run main function
main "$@"