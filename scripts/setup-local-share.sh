#!/bin/bash

# Setup ~/.local/share directories and data files for XDG compliance

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source utilities
source "$SCRIPT_DIR/utils/logger.sh"
source "$SCRIPT_DIR/utils/helpers.sh"

# XDG Data directory
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

setup_local_share() {
    log_header "Setting up ~/.local/share directories"
    
    # Create XDG data directories
    create_xdg_directories
    
    # Link desktop applications (Linux only)
    if [[ "$OS_TYPE" == "Linux" ]]; then
        link_desktop_applications
    fi
    
    # Setup wallpapers directory
    setup_wallpapers
    
    # Create themes and icons directories
    setup_themes_and_icons
    
    log_success "~/.local/share setup completed"
}

create_xdg_directories() {
    log_step "Creating XDG Base Directory structure..."
    
    local directories=(
        "$XDG_DATA_HOME/applications"
        "$XDG_DATA_HOME/icons"
        "$XDG_DATA_HOME/themes"
        "$XDG_DATA_HOME/wallpapers"
        "$XDG_DATA_HOME/fonts"
        "$XDG_DATA_HOME/sounds"
        "$XDG_DATA_HOME/pixmaps"
    )
    
    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            log_info "Created directory: $dir"
        else
            log_debug "Directory exists: $dir"
        fi
    done
    
    log_success "XDG directories created"
}

link_desktop_applications() {
    log_step "Linking desktop application entries..."
    
    local app_files=(
        "kitty.desktop"
        "fastfetch.desktop" 
        "lazygit.desktop"
        "gmail-pwa.desktop"
        "google-calendar-pwa.desktop"
        "youtube-music-pwa.desktop"
        "whatsapp-pwa.desktop"
        "google-photos-pwa.desktop"
        "chatgpt-pwa.desktop"
        "gemini-pwa.desktop"
        "neovim-dotfiles.desktop"
        "dev-workspace.desktop"
        "dotfiles-config.desktop"
    )
    
    for app_file in "${app_files[@]}"; do
        local source="$DOTFILES_DIR/local/share/applications/$app_file"
        local target="$XDG_DATA_HOME/applications/$app_file"
        
        if [[ -f "$source" ]]; then
            create_symlink "$source" "$target"
            log_info "Linked desktop entry: $app_file"
        else
            log_warn "Desktop entry not found: $source"
        fi
    done
    
    # Update desktop database if available
    if command -v update-desktop-database >/dev/null 2>&1; then
        log_info "Updating desktop database..."
        update-desktop-database "$XDG_DATA_HOME/applications" 2>/dev/null || true
    fi
    
    log_success "Desktop applications linked"
}

setup_wallpapers() {
    log_step "Setting up wallpapers directory..."
    
    # Create wallpapers directory
    mkdir -p "$XDG_DATA_HOME/wallpapers"
    
    # Generate wallpapers if ImageMagick is available
    if command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1; then
        log_info "Generating Catppuccin wallpapers..."
        
        # Set DOTFILES_DIR for the wallpaper generator
        DOTFILES_DIR="$DOTFILES_DIR" "$DOTFILES_DIR/scripts/generate-wallpapers.sh" all 1920x1080 2>/dev/null || {
            log_warn "Failed to generate wallpapers, but continuing..."
        }
        
        # Install generated wallpapers
        "$DOTFILES_DIR/scripts/generate-wallpapers.sh" install 2>/dev/null || {
            log_warn "Failed to install wallpapers, but continuing..."
        }
    else
        log_info "ImageMagick not available, skipping wallpaper generation"
        log_info "Install imagemagick package to enable wallpaper generation"
    fi
    
    log_success "Wallpapers directory setup completed"
}

setup_themes_and_icons() {
    log_step "Setting up themes and icons directories..."
    
    # Create theme directories
    mkdir -p "$XDG_DATA_HOME/themes"
    mkdir -p "$XDG_DATA_HOME/icons/hicolor"
    
    # Create icon theme structure
    local icon_sizes=("16x16" "24x24" "32x32" "48x48" "64x64" "128x128" "256x256")
    local icon_categories=("apps" "actions" "devices" "places" "mimetypes")
    
    for size in "${icon_sizes[@]}"; do
        for category in "${icon_categories[@]}"; do
            mkdir -p "$XDG_DATA_HOME/icons/hicolor/$size/$category"
        done
    done
    
    log_success "Themes and icons directories created"
}

# Show what would be created
show_directories() {
    cat << EOF
XDG Data Directories that will be created in $XDG_DATA_HOME:

├── applications/          # Desktop application entries
│   ├── kitty.desktop
│   ├── fastfetch.desktop
│   └── lazygit.desktop
├── icons/                 # Custom icons and icon themes
│   └── hicolor/           # Default icon theme structure
├── themes/                # Custom GTK/Qt themes
├── wallpapers/            # Desktop wallpapers
│   └── catppuccin-*.png   # Generated Catppuccin wallpapers
├── fonts/                 # User-specific fonts
├── sounds/                # Sound files and themes
└── pixmaps/               # Legacy icon location

EOF
}

# Main function
main() {
    case "${1:-setup}" in
        "setup")
            setup_local_share
            ;;
        "show"|"list")
            show_directories
            ;;
        "wallpapers")
            setup_wallpapers
            ;;
        "apps"|"applications")
            if [[ "$OS_TYPE" == "Linux" ]]; then
                link_desktop_applications
            else
                log_info "Desktop applications only supported on Linux"
            fi
            ;;
        "help"|"-h"|"--help")
            cat << EOF
Setup ~/.local/share directories for XDG compliance

USAGE:
    $0 [COMMAND]

COMMANDS:
    setup          Setup all ~/.local/share directories (default)
    show           Show directory structure that will be created
    wallpapers     Setup wallpapers directory only
    applications   Setup desktop applications only (Linux)
    help           Show this help

EXAMPLES:
    $0             # Full setup
    $0 show        # Preview directory structure
    $0 wallpapers  # Generate wallpapers only

EOF
            ;;
        *)
            log_error "Unknown command: $1"
            main "help"
            exit 1
            ;;
    esac
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi