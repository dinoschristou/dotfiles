#!/bin/bash

# Swaybg wallpaper configuration script
# This script sets up wallpapers for Sway/Wayland environments

# Colors matching Catppuccin Macchiato theme
BASE_COLOR="#24273a"
SURFACE_COLOR="#363a4f"
BLUE_COLOR="#8aadf4"
LAVENDER_COLOR="#b7bdf8"

# Wallpaper directory
WALLPAPER_DIR="$HOME/.local/share/wallpapers"
DOTFILES_WALLPAPER_DIR="$HOME/.config/sway/wallpapers"

# Create wallpaper directories
mkdir -p "$WALLPAPER_DIR"
mkdir -p "$DOTFILES_WALLPAPER_DIR"

# Function to set solid color wallpaper
set_solid_wallpaper() {
    local color="${1:-$BASE_COLOR}"
    echo "Setting solid color wallpaper: $color"
    
    if command -v swaybg >/dev/null 2>&1; then
        # Kill any existing swaybg instances
        pkill swaybg 2>/dev/null || true
        
        # Set solid color background
        swaybg -c "$color" &
        disown
        
        echo "Wallpaper set to solid color: $color"
    else
        echo "swaybg not found. Please install swaybg package."
        return 1
    fi
}

# Function to set image wallpaper
set_image_wallpaper() {
    local image_path="$1"
    local mode="${2:-fill}"  # fill, fit, stretch, tile, center
    
    if [[ ! -f "$image_path" ]]; then
        echo "Image not found: $image_path"
        return 1
    fi
    
    if command -v swaybg >/dev/null 2>&1; then
        # Kill any existing swaybg instances
        pkill swaybg 2>/dev/null || true
        
        # Set image background
        swaybg -i "$image_path" -m "$mode" &
        disown
        
        echo "Wallpaper set to image: $image_path (mode: $mode)"
    else
        echo "swaybg not found. Please install swaybg package."
        return 1
    fi
}

# Function to create a simple gradient wallpaper using ImageMagick (if available)
create_gradient_wallpaper() {
    local output_file="$DOTFILES_WALLPAPER_DIR/catppuccin-gradient.png"
    local width="${1:-1920}"
    local height="${2:-1080}"
    
    if command -v magick >/dev/null 2>&1; then
        echo "Creating Catppuccin gradient wallpaper..."
        magick -size "${width}x${height}" gradient:"$BASE_COLOR"-"$SURFACE_COLOR" "$output_file"
        echo "Gradient wallpaper created: $output_file"
        return 0
    elif command -v convert >/dev/null 2>&1; then
        echo "Creating Catppuccin gradient wallpaper..."
        convert -size "${width}x${height}" gradient:"$BASE_COLOR"-"$SURFACE_COLOR" "$output_file"
        echo "Gradient wallpaper created: $output_file"
        return 0
    else
        echo "ImageMagick not found. Cannot create gradient wallpaper."
        return 1
    fi
}

# Main function
main() {
    case "${1:-solid}" in
        "solid")
            set_solid_wallpaper "${2:-$BASE_COLOR}"
            ;;
        "gradient")
            if create_gradient_wallpaper "${2:-1920}" "${3:-1080}"; then
                set_image_wallpaper "$DOTFILES_WALLPAPER_DIR/catppuccin-gradient.png" "fill"
            else
                echo "Falling back to solid color wallpaper"
                set_solid_wallpaper "$BASE_COLOR"
            fi
            ;;
        "image")
            if [[ -n "$2" ]]; then
                set_image_wallpaper "$2" "${3:-fill}"
            else
                echo "Usage: $0 image <path> [mode]"
                echo "Available modes: fill, fit, stretch, tile, center"
                return 1
            fi
            ;;
        "help"|"-h"|"--help")
            cat << EOF
Swaybg Wallpaper Configuration Script

USAGE:
    $0 [COMMAND] [OPTIONS]

COMMANDS:
    solid [color]           Set solid color wallpaper (default: Catppuccin base)
    gradient [width] [height]  Create and set gradient wallpaper
    image <path> [mode]     Set image wallpaper
    help                    Show this help

EXAMPLES:
    $0 solid               # Set Catppuccin base color
    $0 solid "#1e1e2e"     # Set custom color
    $0 gradient            # Create gradient wallpaper
    $0 gradient 2560 1440  # Create gradient for specific resolution
    $0 image ~/Pictures/wallpaper.jpg fill
    
WALLPAPER MODES:
    fill    - Scale image to fill screen (default)
    fit     - Scale image to fit screen
    stretch - Stretch image to screen size
    tile    - Tile image across screen
    center  - Center image on screen

COLORS (Catppuccin Macchiato):
    Base: $BASE_COLOR
    Surface: $SURFACE_COLOR
    Blue: $BLUE_COLOR
    Lavender: $LAVENDER_COLOR
EOF
            ;;
        *)
            echo "Unknown command: $1"
            echo "Use '$0 help' for usage information"
            return 1
            ;;
    esac
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi