# Dotfiles

A modern, cross-platform dotfiles repository with automated installation for macOS and Linux environments. Optimized for a keyboard-driven development workflow using Wayland/Hyprland on Linux and terminal-centric tools.

## Features

- **Cross-platform support**: macOS and Linux (Ubuntu, Debian, Arch, Fedora)
- **Automated installation**: One-command setup with interactive component selection
- **Modern terminal stack**: Kitty terminal + Zsh + Powerlevel10k + Neovim
- **Desktop environment**: Hyprland/Sway on Linux with Waybar and Wofi
- **Consistent theming**: Catppuccin Macchiato across all applications
- **Development tools**: Pre-configured for Go, Rust, Node.js, and more
- **PWA integration**: Desktop entries for Gmail, Calendar, ChatGPT, etc.

## Quick Start

### One-Command Installation

```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The installer will detect your system and guide you through an interactive setup process.

### Installation Options

```bash
# Interactive installation (recommended)
./install.sh

# Install everything
./install.sh --all

# Install specific components
./install.sh --shell --neovim --fonts

# Minimal installation (shell + neovim)
./install.sh --minimal

# Install additional applications
./install.sh --applications

# Non-interactive mode
./install.sh --all --non-interactive

# Update existing installation
./install.sh --update
```

## Components

### Git Configuration
- **Automated setup** of global Git configuration
- **Interactive prompts** for user name and email during installation
- **Pre-configured aliases** and color settings
- **Global gitignore** for common development files

### Shell Configuration
- **Zsh** with extensive customizations
- **Powerlevel10k** prompt theme
- **Advanced history management** (500k entries)
- **Auto-suggestions and syntax highlighting**
- **fzf integration** for fuzzy finding

### Development Environment
- **Neovim** with LazyVim framework and Catppuccin Macchiato theme
- **Vim** with Vundle plugin manager and Catppuccin theme
- **Visual Studio Code** for GUI editing
- **LSP support** via Mason (Neovim) and built-in (VS Code)
- **Telescope** for fuzzy finding
- **Treesitter** for syntax highlighting
- **Git** with pre-configured aliases and colors
- **GitHub CLI** with interactive authentication setup

### Desktop Environment (Linux)
- **Hyprland** (primary) or **Sway** (fallback) Wayland compositors
- **Hyprlock** screen locker for Hyprland
- **Hypridle** idle management daemon
- **Waybar** status bar
- **Wofi** application launcher
- **Mako** notification daemon
- **Kitty** terminal emulator

### Applications & Tools
- **1Password** password manager
- **Google Chrome** web browser
- **VLC** media player
- **Obsidian** note-taking
- **btop** modern system monitor with Catppuccin theme
- **Tailscale** VPN mesh networking
- **Rectangle** window management (macOS)
- **Wireshark** network protocol analyzer
- **PWA entries** for web applications

### Development Tools
- **zoxide** smart directory navigation
- **Ansible** configuration management and automation
- **Hugo** static site generator
- **pre-commit** Git pre-commit hooks framework
- **uv** modern Python package manager
- **GitHub CLI** with authentication integration

## Manual Installation

If you prefer to set up configurations manually:

### Shell Configuration
```bash
# Link shell configurations
ln -sf ~/.dotfiles/zshrc ~/.zshrc
ln -sf ~/.dotfiles/p10k.zsh ~/.p10k.zsh

# Change default shell to zsh
chsh -s $(which zsh)
```

### Neovim Configuration
```bash
# Link Neovim configuration
ln -sf ~/.dotfiles/config/nvim ~/.config/nvim
```

### Terminal Configuration
```bash
# Link Kitty configuration
ln -sf ~/.dotfiles/config/kitty ~/.config/kitty
```

### Git Configuration
```bash
# Link Git configuration
ln -sf ~/.dotfiles/gitconfig ~/.gitconfig

# Configure user settings
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## Font Installation

Fonts are automatically installed via the main installer when you select the `--fonts` option. Essential Nerd Fonts (FiraCode, JetBrainsMono, Hack) are included for optimal terminal experience.

## Platform-Specific Notes

### macOS
- Uses **Homebrew** for package management
- Includes **iTerm2** integration
- **Rectangle** for window management
- **Tailscale** for VPN mesh networking
- Compatible with both Intel and Apple Silicon

### Linux
#### Ubuntu/Debian
- Uses **APT** package manager
- Includes **Wayland** desktop environment setup
- **Tailscale** VPN with official repository
- Supports both X11 and Wayland

#### Arch Linux
- Uses **pacman** and **yay** (AUR)
- **Tailscale** from official repositories
- Includes **printer support** with CUPS
- Optimized for rolling release

#### Fedora
- Uses **DNF** package manager
- Includes **RPM Fusion** repositories
- **Tailscale** with official repository setup
- **Hyprland** via COPR repository

## Customization

### Package Customization

The dotfiles system uses centralized package configurations that make it easy to add or modify packages without editing core installation scripts.

#### Adding Custom Packages

```bash
# Create custom package configuration
./scripts/manage-packages.sh template

# Add a package to your custom list
./scripts/manage-packages.sh add htop

# Edit your custom configuration
./scripts/manage-packages.sh edit

# Install all packages (including custom ones)
./scripts/manage-packages.sh install
```

#### Package Management Commands

```bash
# List all available packages
./scripts/manage-packages.sh list

# List packages by category
./scripts/manage-packages.sh list -c essential
./scripts/manage-packages.sh list -c development
./scripts/manage-packages.sh list -c fonts
./scripts/manage-packages.sh list -c desktop

# View your custom packages
./scripts/manage-packages.sh list-custom

# Remove a custom package
./scripts/manage-packages.sh remove package-name
```

#### Custom Package Configuration

Your custom packages are stored in `scripts/packages/custom/packages.yaml`. Example configuration:

```yaml
# Custom essential tools
custom_essential:
  btop:  # Modern alternative to htop
    macos: btop
    linux: btop
    
  network-tools:
    linux: net-tools
    macos: []  # Skip on macOS

# Custom development tools
custom_development:
  database-client:
    linux: postgresql-client
    macos: postgresql
    
  container-runtime:
    all: docker  # Same name on all platforms

# Custom desktop applications (Linux only)  
custom_desktop:
  media-editor:
    linux: gimp
    skip_platforms: [macos]
    
  communication:
    install_method: manual  # Requires special installation
    description: "Discord messaging app"
```

#### Package Configuration Structure

The system organizes packages into categories:

- **Essential**: Core CLI tools (`scripts/packages/config/essential.yaml`)
- **Development**: Programming tools (`scripts/packages/config/development.yaml`)  
- **Fonts**: Typography (`scripts/packages/config/fonts.yaml`)
- **Desktop**: Linux desktop apps (`scripts/packages/config/desktop.yaml`)

Each package can specify platform-specific names:

```yaml
package-name:
  macos: homebrew-package-name
  ubuntu: apt-package-name
  arch: pacman-package-name
  fedora: dnf-package-name
  symlink_as: alternative-command-name
```

### Host-Specific Configurations

Create optional files for host-specific shell customizations:

```bash
# Host-specific shell customizations
~/.host_shell

# Work-specific shell customizations  
~/.work_shell

# Linux-specific shell customizations
~/.linux_shell
```

These files will be automatically sourced by the shell configuration if they exist.

### Configuration Structure

```
~/.dotfiles/
├── config/           # XDG-compliant app configurations
│   ├── hypr/        # Hyprland configuration
│   ├── kitty/       # Kitty terminal configuration
│   ├── nvim/        # Neovim configuration
│   └── waybar/      # Waybar configuration
├── scripts/         # Installation and utility scripts
│   ├── installers/      # Component installers
│   ├── packages/
│   │   ├── config/      # Centralized package definitions
│   │   │   ├── essential.yaml
│   │   │   ├── development.yaml
│   │   │   ├── fonts.yaml
│   │   │   └── desktop.yaml
│   │   ├── custom/      # Your custom package configurations
│   │   └── essential/   # Legacy OS-specific installers
│   ├── utils/           # Utility functions
│   └── manage-packages.sh # Package management utility
├── zshrc            # Main Zsh configuration
├── p10k.zsh         # Powerlevel10k configuration
├── gitconfig        # Git configuration
└── install.sh       # Main installer
```

## Health Check

Verify your installation:

```bash
./scripts/validation/health-check.sh
```

This will check:
- ✅ Shell configuration
- ✅ Git configuration and user settings
- ✅ Neovim setup and plugins
- ✅ Development tools
- ✅ Desktop environment (Linux)

## Troubleshooting

### Common Issues

**Shell not loading configuration:**
```bash
# Restart terminal or reload configuration
source ~/.zshrc
```

**Neovim plugins not working:**
```bash
# Launch Neovim to trigger plugin installation
nvim
# Then run health check
:checkhealth
```

**Git user configuration not set:**
```bash
# Configure your Git user settings manually
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

**Font rendering issues:**
```bash
# Install or reinstall fonts
./scripts/install-font.sh FiraCode
```

**Desktop environment not available (Linux):**
```bash
# Log out and select Hyprland/Sway from display manager
# Or check if compositor is installed
which hyprland
which sway
```

### Getting Help

1. Check the **health check** output: `./scripts/validation/health-check.sh`
2. Review **log output** during installation
3. Ensure your OS is supported (macOS, Ubuntu, Debian, Arch, Fedora)
4. Verify **dependencies** are installed for your platform

## Theme

This configuration uses the **Catppuccin Macchiato** color scheme consistently across:
- Terminal (Kitty)
- Editors (Neovim with LazyVim, Vim with Vundle)
- Window manager (Hyprland/Sway)
- Screen locker (Hyprlock)
- Status bar (Waybar)
- Application launcher (Wofi)
- Notifications (Mako)
- System monitor (btop)

## Contributing

Feel free to fork this repository and adapt it to your needs. The modular installation system makes it easy to add support for additional:
- Operating systems
- Package managers
- Applications
- Desktop environments

## License

This dotfiles repository is available under the MIT License. See individual applications and tools for their respective licenses.