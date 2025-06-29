#!/bin/bash

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running as root
is_root() {
    [[ $EUID -eq 0 ]]
}

# Check if running in interactive mode
is_interactive() {
    [[ -t 0 && -t 1 ]]
}

# Backup existing file or directory
backup_file() {
    local file="$1"
    local backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)"
    
    if [[ -e "$file" ]]; then
        log_info "Backing up existing $file"
        mkdir -p "$backup_dir"
        mv "$file" "$backup_dir/"
        log_success "Backed up to $backup_dir/$(basename "$file")"
    fi
}

# Create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    
    if [[ ! -e "$source" ]]; then
        log_error "Source file does not exist: $source"
        return 1
    fi
    
    # Backup existing target if it exists and is not a symlink to our source
    if [[ -e "$target" ]] && [[ "$(readlink "$target")" != "$source" ]]; then
        backup_file "$target"
    fi
    
    # Create directory for target if needed
    mkdir -p "$(dirname "$target")"
    
    # Create symlink
    ln -sf "$source" "$target"
    log_success "Created symlink: $target -> $source"
}

# Download file with retry
download_file() {
    local url="$1"
    local output="$2"
    local retries=3
    
    for ((i=1; i<=retries; i++)); do
        if curl -fsSL "$url" -o "$output"; then
            log_success "Downloaded $url"
            return 0
        else
            log_warn "Download attempt $i failed for $url"
            [[ $i -lt $retries ]] && sleep 2
        fi
    done
    
    log_error "Failed to download $url after $retries attempts"
    return 1
}

# Check if package is installed
package_installed() {
    local package="$1"
    local os_type="$2"
    
    case "$os_type" in
        "Darwin")
            brew list "$package" &>/dev/null
            ;;
        "Ubuntu"|"Debian")
            dpkg -l "$package" &>/dev/null
            ;;
        "Arch")
            pacman -Q "$package" &>/dev/null
            ;;
        "Fedora")
            rpm -q "$package" &>/dev/null
            ;;
        *)
            log_error "Unknown OS type: $os_type"
            return 1
            ;;
    esac
}

# Install package if not already installed
install_package_if_missing() {
    local package="$1"
    local os_type="$2"
    
    if package_installed "$package" "$os_type"; then
        log_debug "Package already installed: $package"
        return 0
    fi
    
    log_info "Installing package: $package"
    case "$os_type" in
        "Darwin")
            brew install "$package"
            ;;
        "Ubuntu"|"Debian")
            sudo apt-get install -y "$package"
            ;;
        "Arch")
            sudo pacman -S --noconfirm "$package"
            ;;
        "Fedora")
            sudo dnf install -y "$package"
            ;;
        *)
            log_error "Unknown OS type: $os_type"
            return 1
            ;;
    esac
}

# Get absolute path
get_absolute_path() {
    local path="$1"
    if [[ -d "$path" ]]; then
        (cd "$path" && pwd)
    elif [[ -f "$path" ]]; then
        echo "$(cd "$(dirname "$path")" && pwd)/$(basename "$path")"
    else
        echo "$path"
    fi
}

# Check if directory is git repository
is_git_repo() {
    local dir="${1:-.}"
    git -C "$dir" rev-parse --git-dir >/dev/null 2>&1
}