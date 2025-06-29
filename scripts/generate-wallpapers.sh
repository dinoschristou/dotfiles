#!/bin/bash

# Generate Catppuccin Macchiato wallpapers for ~/.local/share/wallpapers

set -e

# Colors from Catppuccin Macchiato
declare -A CATPPUCCIN_COLORS=(
    ["base"]="#24273a"
    ["mantle"]="#1e2030"
    ["crust"]="#181926"
    ["surface0"]="#363a4f"
    ["surface1"]="#494d64"
    ["surface2"]="#5b6078"
    ["overlay0"]="#6e738d"
    ["overlay1"]="#8087a2"
    ["overlay2"]="#939ab7"
    ["subtext0"]="#a5adcb"
    ["subtext1"]="#b8c0e0"
    ["text"]="#cad3f5"
    ["lavender"]="#b7bdf8"
    ["blue"]="#8aadf4"
    ["sapphire"]="#7dc4e4"
    ["sky"]="#91d7e3"
    ["teal"]="#8bd5ca"
    ["green"]="#a6da95"
    ["yellow"]="#eed49f"
    ["peach"]="#f5a97f"
    ["maroon"]="#ee99a0"
    ["red"]="#ed8796"
    ["mauve"]="#c6a0f6"
    ["pink"]="#f5bde6"
    ["flamingo"]="#f0c6c6"
    ["rosewater"]="#f4dbd6"
)

# Default wallpaper dimensions
DEFAULT_RESOLUTIONS=(
    "1920x1080"
    "2560x1440"
    "3840x2160"
    "1366x768"
    "1440x900"
)

# Output directory
WALLPAPER_DIR="$HOME/.local/share/wallpapers"
DOTFILES_WALLPAPER_DIR="$DOTFILES_DIR/local/share/wallpapers"

# Ensure directories exist
mkdir -p "$WALLPAPER_DIR" "$DOTFILES_WALLPAPER_DIR"

log_info() {
    echo "[INFO] $*"
}

log_success() {
    echo "[SUCCESS] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Check if ImageMagick is available
check_imagemagick() {
    if command -v magick >/dev/null 2>&1; then
        CONVERT_CMD="magick"
        return 0
    elif command -v convert >/dev/null 2>&1; then
        CONVERT_CMD="convert"
        return 0
    else
        log_error "ImageMagick not found. Please install imagemagick package."
        return 1
    fi
}

# Generate solid color wallpaper
generate_solid() {
    local color="$1"
    local resolution="$2"
    local name="$3"
    
    local output_file="$DOTFILES_WALLPAPER_DIR/catppuccin-${name}-${resolution}.png"
    
    log_info "Generating solid wallpaper: $name ($color) at $resolution"
    
    $CONVERT_CMD -size "$resolution" "xc:$color" "$output_file"
    
    if [[ -f "$output_file" ]]; then
        log_success "Created: $output_file"
        return 0
    else
        log_error "Failed to create: $output_file"
        return 1
    fi
}

# Generate gradient wallpaper
generate_gradient() {
    local color1="$1"
    local color2="$2"
    local resolution="$3"
    local name1="$4"
    local name2="$5"
    local direction="${6:-vertical}"
    
    local output_file="$DOTFILES_WALLPAPER_DIR/catppuccin-gradient-${name1}-${name2}-${resolution}.png"
    
    log_info "Generating gradient wallpaper: $name1 to $name2 at $resolution ($direction)"
    
    case "$direction" in
        "horizontal")
            $CONVERT_CMD -size "$resolution" gradient:"$color1"-"$color2" -rotate 90 "$output_file"
            ;;
        "diagonal")
            $CONVERT_CMD -size "$resolution" gradient:"$color1"-"$color2" -swirl 90 "$output_file"
            ;;
        *)
            $CONVERT_CMD -size "$resolution" gradient:"$color1"-"$color2" "$output_file"
            ;;
    esac
    
    if [[ -f "$output_file" ]]; then
        log_success "Created: $output_file"
        return 0
    else
        log_error "Failed to create: $output_file"
        return 1
    fi
}

# Generate all solid color wallpapers
generate_all_solid() {
    local resolutions=("$@")
    [[ ${#resolutions[@]} -eq 0 ]] && resolutions=("${DEFAULT_RESOLUTIONS[@]}")
    
    log_info "Generating solid color wallpapers..."
    
    # Generate primary backgrounds
    for resolution in "${resolutions[@]}"; do
        generate_solid "${CATPPUCCIN_COLORS[base]}" "$resolution" "base"
        generate_solid "${CATPPUCCIN_COLORS[mantle]}" "$resolution" "mantle"
        generate_solid "${CATPPUCCIN_COLORS[crust]}" "$resolution" "crust"
        generate_solid "${CATPPUCCIN_COLORS[surface0]}" "$resolution" "surface0"
    done
}

# Generate all gradient wallpapers
generate_all_gradients() {
    local resolutions=("$@")
    [[ ${#resolutions[@]} -eq 0 ]] && resolutions=("${DEFAULT_RESOLUTIONS[@]}")
    
    log_info "Generating gradient wallpapers..."
    
    # Popular gradient combinations
    for resolution in "${resolutions[@]}"; do
        # Dark gradients
        generate_gradient "${CATPPUCCIN_COLORS[base]}" "${CATPPUCCIN_COLORS[surface0]}" "$resolution" "base" "surface0" "vertical"
        generate_gradient "${CATPPUCCIN_COLORS[mantle]}" "${CATPPUCCIN_COLORS[base]}" "$resolution" "mantle" "base" "vertical"
        
        # Colorful gradients
        generate_gradient "${CATPPUCCIN_COLORS[base]}" "${CATPPUCCIN_COLORS[blue]}" "$resolution" "base" "blue" "diagonal"
        generate_gradient "${CATPPUCCIN_COLORS[base]}" "${CATPPUCCIN_COLORS[mauve]}" "$resolution" "base" "mauve" "diagonal"
        generate_gradient "${CATPPUCCIN_COLORS[surface0]}" "${CATPPUCCIN_COLORS[lavender]}" "$resolution" "surface0" "lavender" "horizontal"
    done
}

# Install wallpapers to system
install_wallpapers() {
    log_info "Installing wallpapers to $WALLPAPER_DIR..."
    
    # Copy all generated wallpapers
    if [[ -d "$DOTFILES_WALLPAPER_DIR" ]]; then
        cp -r "$DOTFILES_WALLPAPER_DIR"/*.png "$WALLPAPER_DIR/" 2>/dev/null || true
        log_success "Wallpapers installed to $WALLPAPER_DIR"
    fi
}

# Show usage
show_usage() {
    cat << EOF
Catppuccin Wallpaper Generator

USAGE:
    $0 [COMMAND] [OPTIONS]

COMMANDS:
    solid [resolutions...]     Generate solid color wallpapers
    gradients [resolutions...] Generate gradient wallpapers
    all [resolutions...]       Generate all wallpapers
    install                    Install generated wallpapers to ~/.local/share/wallpapers
    clean                      Remove generated wallpapers
    help                       Show this help

EXAMPLES:
    $0 all                     # Generate all wallpapers in default resolutions
    $0 solid 1920x1080         # Generate solid wallpapers in 1080p
    $0 gradients 2560x1440 3840x2160  # Generate gradients in specific resolutions
    $0 install                 # Install wallpapers to system

DEFAULT RESOLUTIONS:
    ${DEFAULT_RESOLUTIONS[*]}

EOF
}

# Clean generated wallpapers
clean_wallpapers() {
    log_info "Cleaning generated wallpapers..."
    rm -f "$DOTFILES_WALLPAPER_DIR"/*.png 2>/dev/null || true
    log_success "Cleaned wallpapers from $DOTFILES_WALLPAPER_DIR"
}

# Main function
main() {
    # Check for ImageMagick
    if ! check_imagemagick; then
        exit 1
    fi
    
    case "${1:-all}" in
        "solid")
            shift
            generate_all_solid "$@"
            ;;
        "gradients")
            shift
            generate_all_gradients "$@"
            ;;
        "all")
            shift
            generate_all_solid "$@"
            generate_all_gradients "$@"
            ;;
        "install")
            install_wallpapers
            ;;
        "clean")
            clean_wallpapers
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        *)
            log_error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi