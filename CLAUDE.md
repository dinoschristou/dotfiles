# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for managing configuration files across macOS and Linux environments. The configuration is optimized for a modern, keyboard-driven development workflow using Wayland/Hyprland on Linux and terminal-centric tools.

## Key Commands

### Font Management
Fonts are automatically installed via the main installer when the `--fonts` option is selected. Essential Nerd Fonts are included for optimal terminal experience.

### Shell Configuration
The main shell configuration is in `zshrc` with OS-specific conditionals. No automated installation - configurations must be manually symlinked or copied to home directory.

### Development Environment Setup
- **Neovim**: Uses LazyVim framework with Catppuccin Macchiato theme
- **Vim**: Uses Vundle plugin manager with Catppuccin Macchiato theme and extensive plugin suite
- **VS Code**: Cross-platform GUI editor included in installation
- **Git**: Pre-configured with aliases and color settings in `gitconfig`
- **GitHub CLI**: Automated installation with interactive authentication setup
- **Terminal**: Kitty configuration with Catppuccin Macchiato theme as default terminal

## Architecture

### Configuration Structure
- `config/`: XDG-compliant application configurations
- `scripts/`: Utility scripts for system setup
- Root-level files: Shell configurations (zshrc, etc.)
- `local/`: Local data and themes

### Cross-Platform Design
The repository uses OS detection (`$OSTYPE`) to handle platform differences:
- **macOS**: Homebrew package management, iTerm2 integration
- **Linux**: System package managers, Wayland-specific tools

### Desktop Environment Stack (Linux)
- **Primary**: Hyprland (Wayland compositor) with hyprlock and hypridle
- **Fallback**: Sway (i3-compatible Wayland compositor)  
- **Supporting tools**: Waybar (status bar), Wofi (launcher), Mako (notifications), swaybg (wallpaper daemon)

### Theme System
Consistent Catppuccin Macchiato color scheme across:
- Terminal (Kitty)
- Editors (Neovim with LazyVim, Vim with Vundle)
- Window manager (Hyprland/Sway with sourced color definitions)
- Screen locker (Hyprlock)
- Status bar (Waybar)
- Application launcher (Wofi)
- Notifications (Mako)
- System monitor (btop)
- Git UI (Lazygit)
- System info (Fastfetch)
- Terminal multiplexer (Tmux)

## Important File Locations

### Core Configurations
- `zshrc`: Main shell configuration with extensive customizations
- `config/nvim/`: Modern Neovim setup with LSP support
- `config/hypr/hyprland.conf`: Primary window manager configuration
- `config/hypr/macchiato.conf`: Catppuccin Macchiato color definitions for Hyprland
- `config/kitty/kitty.conf`: Terminal emulator settings

### Platform-Specific Files
- **macOS**: Homebrew paths, iTerm2 integration in zshrc
- **Linux**: Wayland tools, manual package management

### Extension Points
- `~/.host_shell`: Host-specific shell customizations (sourced if exists)
- `~/.work_shell`: Work-specific shell customizations (sourced if exists)
- `~/.linux_shell`: Linux-specific shell customizations (sourced if exists)

### XDG User Data Structure
- `~/.local/share/applications/`: Desktop application entries (Linux)
  - Static `.desktop` files for all applications including PWAs
  - Includes development tools, web applications, and system utilities
  - All entries use consistent theming and Kitty terminal integration
- `~/.local/share/wallpapers/`: Catppuccin-themed wallpapers
- `~/.local/share/themes/`: Custom GTK/Qt themes
- `~/.local/share/icons/`: Custom icon themes
- `~/.local/share/fonts/`: User-specific fonts
- `~/.config/mimeapps.list`: MIME type associations favoring development tools

## Development Workflow

### Editor Setup
Neovim is the primary editor with:
- LSP support via Mason
- Telescope for fuzzy finding
- Treesitter for syntax highlighting
- Modern plugin ecosystem

### Terminal Environment
- Zsh with Powerlevel10k prompt theme
- Advanced history management (500k entries)
- zsh-autosuggestions and fast-syntax-highlighting
- fzf integration for fuzzy finding

### Infrastructure Tools
Includes configurations for:
- Kubernetes (kubectl)
- Cloud providers (GCP SDK)
- Secret management (SOPS)
- Monitoring (Prometheus tooling)

## Installation Notes

This repository includes an automated installer (`install.sh`) that handles:
1. System detection and package management
2. Configuration symlinking to appropriate locations
3. Platform-specific dependency installation
4. Component-based installation (shell, neovim, desktop, fonts, etc.)

Manual installation is also supported by symlinking configurations directly.

## Development Best Practices
- Always make sure the framework is idempotent
- Where possible, we should only use one way of doing things. And configure thing in one place only.
- Desktop entries must be static files in `local/share/applications/` that get symlinked, never created dynamically

## Application Theming Guidelines
- All applications should be themed with Catppuccin Macchiato where possible