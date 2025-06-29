#!/bin/bash

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"

# Source utility functions
source "$SCRIPT_DIR/scripts/utils/logger.sh"
source "$SCRIPT_DIR/scripts/utils/helpers.sh"
source "$SCRIPT_DIR/scripts/utils/prompts.sh"
source "$SCRIPT_DIR/scripts/core/detect-system.sh"

# Installation options
INSTALL_SHELL=false
INSTALL_NEOVIM=false
INSTALL_DESKTOP=false
INSTALL_DEVELOPMENT=false
INSTALL_FONTS=false
INSTALL_APPLICATIONS=false
INSTALL_ALL=false
INTERACTIVE_MODE=true
UPDATE_MODE=false
DRY_RUN_MODE=false

# Show usage information
show_usage() {
    cat << EOF
Dotfiles Installation Script

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help          Show this help message
    -a, --all           Install all components
    -s, --shell         Install shell configuration (zsh, bash)
    -n, --neovim        Install Neovim configuration
    -d, --desktop       Install desktop environment (Linux only)
    -dev, --development Install development tools
    -f, --fonts         Install fonts
    -app, --applications Install additional applications (1Password, Chrome, etc.)
    -u, --update        Update existing installation
    --non-interactive   Run in non-interactive mode
    --minimal           Install minimal setup (shell + git)
    --dry-run           Show what would be installed without making changes
    --test              Run validation tests

EXAMPLES:
    $0                  # Interactive installation
    $0 --all            # Install everything
    $0 --shell --neovim # Install shell and Neovim only
    $0 --minimal        # Minimal installation
    $0 --update         # Update existing installation

EOF
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -a|--all)
                INSTALL_ALL=true
                INSTALL_SHELL=true
                INSTALL_NEOVIM=true
                INSTALL_DEVELOPMENT=true
                INSTALL_FONTS=true
                INSTALL_APPLICATIONS=true
                [[ "$OS_TYPE" == "Linux" ]] && INSTALL_DESKTOP=true
                shift
                ;;
            -s|--shell)
                INSTALL_SHELL=true
                shift
                ;;
            -n|--neovim)
                INSTALL_NEOVIM=true
                shift
                ;;
            -d|--desktop)
                INSTALL_DESKTOP=true
                shift
                ;;
            -dev|--development)
                INSTALL_DEVELOPMENT=true
                shift
                ;;
            -f|--fonts)
                INSTALL_FONTS=true
                shift
                ;;
            -app|--applications)
                INSTALL_APPLICATIONS=true
                shift
                ;;
            -u|--update)
                UPDATE_MODE=true
                shift
                ;;
            --non-interactive)
                INTERACTIVE_MODE=false
                shift
                ;;
            --minimal)
                INSTALL_SHELL=true
                INSTALL_NEOVIM=true
                INTERACTIVE_MODE=false
                shift
                ;;
            --dry-run)
                DRY_RUN_MODE=true
                shift
                ;;
            --test)
                if [[ -f "$SCRIPT_DIR/scripts/test/validate.sh" ]]; then
                    exec "$SCRIPT_DIR/scripts/test/validate.sh"
                else
                    log_error "Validation script not found"
                    exit 1
                fi
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Interactive component selection
interactive_selection() {
    if [[ "$INTERACTIVE_MODE" == false ]]; then
        return
    fi

    log_header "Dotfiles Installation - Component Selection"
    
    echo "Detected system: $OS_NAME ($ARCH)"
    echo "Package manager: $PACKAGE_MANAGER"
    [[ "$OS_TYPE" == "Linux" ]] && echo "Display server: $DISPLAY_SERVER"
    echo

    local components=()
    components+=("Shell configuration (zsh, bash)")
    components+=("Neovim configuration")
    components+=("Development tools (Go, Rust, Node.js)")
    components+=("Fonts (Nerd Fonts)")
    components+=("Applications (1Password, Chrome, VLC, etc.)")
    
    if [[ "$OS_TYPE" == "Linux" ]]; then
        components+=("Desktop environment (Hyprland/Sway)")
    fi

    echo "Select components to install:"
    local selected
    selected=($(multi_select_from_menu "Available components:" "${components[@]}"))

    # Parse selections
    for component in "${selected[@]}"; do
        case "$component" in
            *"Shell configuration"*)
                INSTALL_SHELL=true
                ;;
            *"Neovim"*)
                INSTALL_NEOVIM=true
                ;;
            *"Development tools"*)
                INSTALL_DEVELOPMENT=true
                ;;
            *"Fonts"*)
                INSTALL_FONTS=true
                ;;
            *"Applications"*)
                INSTALL_APPLICATIONS=true
                ;;
            *"Desktop environment"*)
                INSTALL_DESKTOP=true
                ;;
        esac
    done

    echo
    log_info "Selected components:"
    [[ "$INSTALL_SHELL" == true ]] && log_info "  ✓ Shell configuration"
    [[ "$INSTALL_NEOVIM" == true ]] && log_info "  ✓ Neovim configuration"
    [[ "$INSTALL_DEVELOPMENT" == true ]] && log_info "  ✓ Development tools"
    [[ "$INSTALL_FONTS" == true ]] && log_info "  ✓ Fonts"
    [[ "$INSTALL_APPLICATIONS" == true ]] && log_info "  ✓ Applications"
    [[ "$INSTALL_DESKTOP" == true ]] && log_info "  ✓ Desktop environment"
    echo

    if ! ask_yes_no "Proceed with installation?" "y"; then
        log_info "Installation cancelled"
        exit 0
    fi
}

# Install essential packages
install_essential_packages() {
    log_header "Installing Essential Packages"
    source "$SCRIPT_DIR/scripts/packages/essential/$OS_NAME.sh"
    install_essential_packages_for_system
}

# Install additional applications
install_additional_applications() {
    log_step "Installing additional applications for $OS_NAME"
    
    case "$OS_NAME" in
        "macOS")
            source "$SCRIPT_DIR/scripts/packages/essential/$OS_NAME.sh"
            install_desktop_applications
            install_additional_cli_tools
            ;;
        "Ubuntu"|"Debian"|"Fedora"|"Arch")
            source "$SCRIPT_DIR/scripts/packages/essential/$OS_NAME.sh"
            install_desktop_packages
            ;;
        *)
            log_warn "Additional applications not configured for $OS_NAME"
            ;;
    esac
    
    log_success "Additional applications installed"
}

# Install components
install_components() {
    # Git configuration should always be installed if any component is selected
    log_header "Installing Git Configuration"
    source "$SCRIPT_DIR/scripts/installers/git.sh"
    install_git_configuration

    if [[ "$INSTALL_SHELL" == true ]]; then
        log_header "Installing Shell Configuration"
        source "$SCRIPT_DIR/scripts/installers/shell.sh"
        install_shell_configuration
    fi

    if [[ "$INSTALL_NEOVIM" == true ]]; then
        log_header "Installing Neovim Configuration"
        source "$SCRIPT_DIR/scripts/installers/neovim.sh"
        install_neovim_configuration
    fi

    if [[ "$INSTALL_DEVELOPMENT" == true ]]; then
        log_header "Installing Development Tools"
        source "$SCRIPT_DIR/scripts/installers/development.sh"
        install_development_tools
    fi

    if [[ "$INSTALL_FONTS" == true ]]; then
        log_header "Installing Fonts"
        source "$SCRIPT_DIR/scripts/installers/fonts.sh"
        install_fonts
    fi

    if [[ "$INSTALL_APPLICATIONS" == true ]]; then
        log_header "Installing Applications"
        install_additional_applications
    fi

    if [[ "$INSTALL_DESKTOP" == true ]] && [[ "$OS_TYPE" == "Linux" ]]; then
        log_header "Installing Desktop Environment"
        source "$SCRIPT_DIR/scripts/installers/desktop.sh"
        install_desktop_environment
    fi
}

# Post-installation setup
post_installation() {
    log_header "Post-Installation Setup"
    
    # Create desktop entries on Linux
    if [[ "$OS_TYPE" == "Linux" ]]; then
        source "$SCRIPT_DIR/scripts/desktop/create-entries.sh"
        create_desktop_entries
    fi

    # Run health check
    source "$SCRIPT_DIR/scripts/validation/health-check.sh"
    run_health_check

    log_success "Installation completed successfully!"
    
    # Show next steps
    show_next_steps
}

# Show next steps
show_next_steps() {
    log_header "Next Steps"
    
    echo "Your dotfiles have been installed! Here are some next steps:"
    echo
    
    # Check if Git user is configured
    local git_name git_email
    git_name=$(git config --global user.name 2>/dev/null)
    git_email=$(git config --global user.email 2>/dev/null)
    
    if [[ -z "$git_name" ]] || [[ -z "$git_email" ]]; then
        echo "1. Configure your Git user settings:"
        echo "   git config --global user.name \"Your Name\""
        echo "   git config --global user.email \"your.email@example.com\""
        echo
    fi
    
    if [[ "$INSTALL_SHELL" == true ]]; then
        echo "2. Restart your terminal or run: source ~/.zshrc"
        if [[ "$CURRENT_SHELL" != "zsh" ]]; then
            echo "3. Consider changing your default shell to zsh: chsh -s \$(which zsh)"
        fi
    fi
    
    if [[ "$INSTALL_NEOVIM" == true ]]; then
        echo "4. Launch Neovim to complete plugin installation: nvim"
    fi
    
    if [[ "$INSTALL_DESKTOP" == true ]] && [[ "$OS_TYPE" == "Linux" ]]; then
        echo "5. Log out and select Hyprland or Sway from your display manager"
    fi
    
    echo "6. Check the health of your installation: $SCRIPT_DIR/scripts/validation/health-check.sh"
    echo
    echo "For more information, see: $DOTFILES_DIR/CLAUDE.md"
}

# Main installation function
main() {
    # Show banner
    log_header "Dotfiles Automated Installation"
    
    # Detect system
    detect_system
    
    # Check requirements
    if ! check_requirements; then
        exit 1
    fi
    
    # Check sudo if needed
    if ! check_sudo; then
        exit 1
    fi
    
    # Parse arguments
    parse_arguments "$@"
    
    # Interactive selection if needed
    interactive_selection
    
    # Verify we have something to install
    if [[ "$INSTALL_SHELL" == false ]] && [[ "$INSTALL_NEOVIM" == false ]] && 
       [[ "$INSTALL_DESKTOP" == false ]] && [[ "$INSTALL_DEVELOPMENT" == false ]] && 
       [[ "$INSTALL_FONTS" == false ]] && [[ "$INSTALL_APPLICATIONS" == false ]]; then
        log_error "No components selected for installation"
        show_usage
        exit 1
    fi
    
    # Install essential packages first
    install_essential_packages
    
    # Install selected components
    install_components
    
    # Post-installation setup
    post_installation
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi