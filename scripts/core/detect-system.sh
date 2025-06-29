#!/bin/bash

# System detection script
detect_system() {
    # Operating system detection
    case "$OSTYPE" in
        darwin*)
            OS_TYPE="Darwin"
            OS_NAME="macOS"
            PACKAGE_MANAGER="brew"
            ;;
        linux*)
            OS_TYPE="Linux"
            if [[ -f /etc/os-release ]]; then
                source /etc/os-release
                case "$ID" in
                    ubuntu)
                        OS_NAME="Ubuntu"
                        OS_VERSION="$VERSION_ID"
                        PACKAGE_MANAGER="apt"
                        ;;
                    debian)
                        OS_NAME="Debian"
                        OS_VERSION="$VERSION_ID"
                        PACKAGE_MANAGER="apt"
                        ;;
                    arch)
                        OS_NAME="Arch"
                        PACKAGE_MANAGER="pacman"
                        ;;
                    fedora)
                        OS_NAME="Fedora"
                        OS_VERSION="$VERSION_ID"
                        PACKAGE_MANAGER="dnf"
                        ;;
                    *)
                        OS_NAME="Unknown Linux"
                        PACKAGE_MANAGER="unknown"
                        ;;
                esac
            else
                OS_NAME="Unknown Linux"
                PACKAGE_MANAGER="unknown"
            fi
            ;;
        *)
            OS_TYPE="Unknown"
            OS_NAME="Unknown"
            PACKAGE_MANAGER="unknown"
            ;;
    esac

    # Architecture detection
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64|amd64)
            ARCH="x86_64"
            ;;
        arm64|aarch64)
            ARCH="arm64"
            ;;
        *)
            ARCH="unknown"
            ;;
    esac

    # Desktop environment detection (Linux only)
    if [[ "$OS_TYPE" == "Linux" ]]; then
        if [[ -n "$WAYLAND_DISPLAY" ]]; then
            DISPLAY_SERVER="wayland"
        elif [[ -n "$DISPLAY" ]]; then
            DISPLAY_SERVER="x11"
        else
            DISPLAY_SERVER="none"
        fi

        # Detect current desktop environment
        if [[ -n "$XDG_CURRENT_DESKTOP" ]]; then
            DESKTOP_ENV="$XDG_CURRENT_DESKTOP"
        elif [[ -n "$DESKTOP_SESSION" ]]; then
            DESKTOP_ENV="$DESKTOP_SESSION"
        else
            DESKTOP_ENV="unknown"
        fi
    else
        DISPLAY_SERVER="native"
        DESKTOP_ENV="native"
    fi

    # Shell detection
    CURRENT_SHELL=$(basename "$SHELL")

    # Export variables
    export OS_TYPE OS_NAME OS_VERSION PACKAGE_MANAGER ARCH
    export DISPLAY_SERVER DESKTOP_ENV CURRENT_SHELL

    log_debug "System detection complete:"
    log_debug "  OS: $OS_NAME ($OS_TYPE)"
    [[ -n "$OS_VERSION" ]] && log_debug "  Version: $OS_VERSION"
    log_debug "  Architecture: $ARCH"
    log_debug "  Package Manager: $PACKAGE_MANAGER"
    if [[ "$OS_TYPE" == "Linux" ]]; then
        log_debug "  Display Server: $DISPLAY_SERVER"
        log_debug "  Desktop Environment: $DESKTOP_ENV"
    fi
    log_debug "  Current Shell: $CURRENT_SHELL"
}

# Check system requirements
check_requirements() {
    local missing_deps=()

    # Check essential commands
    local required_commands=("curl" "git" "unzip")
    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd"; then
            missing_deps+=("$cmd")
        fi
    done

    # Check package manager
    case "$PACKAGE_MANAGER" in
        "brew")
            if ! command_exists "brew"; then
                missing_deps+=("homebrew")
            fi
            ;;
        "apt")
            if ! command_exists "apt-get"; then
                missing_deps+=("apt")
            fi
            ;;
        "pacman")
            if ! command_exists "pacman"; then
                missing_deps+=("pacman")
            fi
            ;;
        "dnf")
            if ! command_exists "dnf"; then
                missing_deps+=("dnf")
            fi
            ;;
        *)
            log_error "Unsupported package manager: $PACKAGE_MANAGER"
            return 1
            ;;
    esac

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_error "Please install these dependencies before running the installer"
        return 1
    fi

    log_success "All system requirements met"
    return 0
}

# Detect if running in container
is_container() {
    [[ -f /.dockerenv ]] || [[ -f /run/.containerenv ]] || [[ "${container:-}" == "podman" ]]
}

# Check if sudo is available and working
check_sudo() {
    if [[ "$OS_TYPE" != "Darwin" ]] && ! is_root; then
        if ! command_exists "sudo"; then
            log_error "sudo is required but not available"
            return 1
        fi
        
        # Test sudo access
        if ! sudo -n true 2>/dev/null; then
            log_info "Testing sudo access..."
            if ! sudo true; then
                log_error "sudo access required for installation"
                return 1
            fi
        fi
    fi
    return 0
}