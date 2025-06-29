# Testing Guide for Dotfiles Framework

This document provides comprehensive testing strategies for the dotfiles framework to ensure reliability across platforms and components.

## 🧪 Testing Methods

### 1. **Automated Validation Tests**

#### Quick Syntax Validation
```bash
# Run all validation tests
./install.sh --test

# Or run directly
./scripts/test/validate.sh
```

**What it checks:**
- Bash script syntax across all `.sh` files
- YAML configuration file validity  
- Required files existence
- Configuration integrity (theme consistency)
- Symlink target validity
- Install script argument parsing

#### Expected Output:
```
[TEST] Testing Bash script syntax
[PASS] All Bash scripts have valid syntax
[TEST] Testing YAML configuration syntax  
[PASS] All YAML files have valid syntax
...
[SUCCESS] All tests passed! 🎉
```

---

### 2. **Dry-Run Testing**

#### Test Without Making Changes
```bash
# Test specific components
./install.sh --shell --dry-run --non-interactive
./install.sh --development --dry-run --non-interactive
./install.sh --desktop --dry-run --non-interactive

# Test full installation
./install.sh --all --dry-run --non-interactive
```

**What it shows:**
- Which packages would be installed
- Which repositories would be added
- Which configuration files would be linked
- Which post-install actions would run

#### Expected Output:
```
[DRY-RUN STEP] Installing shell configuration
[DRY-RUN] Would execute: sudo apt-get install -y zsh
[DRY-RUN] Would execute: create_symlink /path/to/zshrc ~/.zshrc
...
```

---

### 3. **Docker-Based Testing**

#### Test on Multiple Linux Distributions
```bash
# Test all distributions with shell component
./scripts/test/docker-test.sh all shell

# Test specific distribution interactively
./scripts/test/docker-test.sh interactive ubuntu:22.04

# List available distributions
./scripts/test/docker-test.sh list
```

**Supported Distributions:**
- Ubuntu 22.04, 20.04
- Debian Bullseye
- Arch Linux (latest)
- Fedora 38

**What it tests:**
- Package installation on different distros
- Repository setup
- Configuration deployment
- Platform-specific differences

---

### 4. **Health Check Validation**

#### Post-Installation Verification
```bash
# Run comprehensive health check
./scripts/validation/health-check.sh
```

**What it checks:**
- All installed applications and tools
- Configuration file linking
- Shell setup and plugins
- Git configuration
- Development tools availability
- Desktop environment (Linux)
- Font installation
- Neovim health

#### Expected Output:
```
[STEP] Checking shell configuration...
✓ zsh is installed
✓ ~/.zshrc (symlinked)
[STEP] Checking development tools...
✓ lazygit (Terminal Git UI) - 0.40.2
✓ fastfetch (Modern system info tool) - 2.3.3
...
🎉 All checks passed! Your dotfiles installation is healthy.
```

---

## 📋 Manual Testing Checklist

### Pre-Installation Testing

#### System Requirements
- [ ] Target OS is supported (macOS, Ubuntu, Debian, Arch, Fedora)
- [ ] User has sudo privileges (Linux only)
- [ ] Internet connection available
- [ ] Git is installed
- [ ] Curl/wget available

#### Repository Integrity
- [ ] Clone repository successfully
- [ ] Run `./install.sh --test` passes
- [ ] Run `./install.sh --help` shows usage
- [ ] Run `./install.sh --dry-run --minimal` completes

### Component Testing

#### Shell Component (`--shell`)
- [ ] Dry-run shows expected packages
- [ ] Installation completes without errors
- [ ] `~/.zshrc` is properly symlinked
- [ ] `~/.tmux.conf` is properly symlinked
- [ ] Powerlevel10k is installed in `~/powerlevel10k/`
- [ ] Lazygit config is linked to `~/.config/lazygit/config.yml`
- [ ] Fastfetch config is linked to `~/.config/fastfetch/config.jsonc`
- [ ] New shell session loads without errors
- [ ] Aliases work: `lg`, `ff`, `sysinfo`
- [ ] Shell prompt shows Powerlevel10k theme

#### Development Component (`--development`)  
- [ ] Essential development tools installed
- [ ] Lazygit opens with Catppuccin theme
- [ ] Fastfetch shows system info with Catppuccin colors
- [ ] Docker installed and user added to docker group (Linux)
- [ ] GitHub CLI authentication works
- [ ] Package manager handles platform differences

#### Desktop Component (`--desktop`) - Linux Only
- [ ] Wayland/X11 tools installed
- [ ] Window manager available (Hyprland/Sway)
- [ ] Kitty terminal has Catppuccin theme
- [ ] Waybar, Wofi, Mako have consistent theming
- [ ] Image viewer (imv) works
- [ ] Bluetooth manager (blueberry) available
- [ ] Note-taking apps installed

#### Font Component (`--fonts`)
- [ ] Nerd Fonts installed
- [ ] Fonts available in terminal
- [ ] Font consistency across applications

### Integration Testing

#### Theme Consistency
- [ ] All applications use Catppuccin Macchiato colors
- [ ] Color scheme consistent across:
  - [ ] Kitty terminal
  - [ ] Lazygit interface  
  - [ ] Fastfetch output
  - [ ] Tmux status bar
  - [ ] Sway window decorations
  - [ ] Waybar status bar
  - [ ] Wofi launcher
  - [ ] Mako notifications

#### Configuration Linking
- [ ] All config files properly symlinked
- [ ] No broken symlinks exist
- [ ] Configs load without errors
- [ ] Changes to dotfiles reflect in linked configs

#### Idempotency Testing
- [ ] Re-running installation doesn't cause errors
- [ ] Existing packages aren't reinstalled unnecessarily
- [ ] Repository additions are skipped if already present
- [ ] Configuration links are preserved

### Platform-Specific Testing

#### macOS
- [ ] Homebrew packages install correctly
- [ ] Cask applications install via Homebrew
- [ ] iTerm2 integration works
- [ ] macOS-specific aliases function

#### Ubuntu/Debian
- [ ] APT repositories added correctly
- [ ] Package names resolve properly
- [ ] Symlinks created for renamed packages (bat→batcat)
- [ ] Third-party app installations work

#### Arch Linux
- [ ] Pacman packages install
- [ ] AUR helper (yay) works if available
- [ ] Arch-specific package names used

#### Fedora
- [ ] DNF packages install correctly
- [ ] COPR repositories added when needed
- [ ] Fedora-specific configurations applied

### Error Handling Testing

#### Network Issues
- [ ] Graceful handling of download failures
- [ ] Repository addition failures logged properly
- [ ] Installation continues with available packages

#### Permission Issues
- [ ] Sudo prompts work correctly
- [ ] File permission errors handled
- [ ] User directory creation works

#### Dependency Issues
- [ ] Missing dependencies reported clearly
- [ ] Installation order prevents conflicts
- [ ] Optional dependencies handled gracefully

---

## 🚨 Common Issues and Solutions

### Package Manager Issues
```bash
# If yq is missing
sudo apt install yq  # Ubuntu/Debian
brew install yq       # macOS

# If package conflicts occur
sudo apt update && sudo apt upgrade  # Update package lists
```

### Configuration Issues
```bash
# If symlinks are broken
./install.sh --shell  # Re-run component installation

# If shell doesn't load properly
zsh -c "source ~/.zshrc"  # Test configuration manually
```

### Permission Issues
```bash
# If Docker group membership doesn't work
newgrp docker  # Activate group membership
# Or logout/login

# If sudo issues occur
sudo -v  # Refresh sudo credentials
```

---

## ⚡ Quick Test Commands

```bash
# Validate everything
./install.sh --test

# Test installation (safe)
./install.sh --minimal --dry-run --non-interactive

# Health check after installation
./scripts/validation/health-check.sh

# Test shell configuration
zsh -c "source ~/.zshrc && echo 'OK'"

# Test Catppuccin theme consistency
grep -r "#24273a" config/  # Should find base color in configs

# Test Docker cross-platform
./scripts/test/docker-test.sh all shell
```

---

## 📊 Test Coverage

The testing framework covers:

✅ **Syntax Validation** - All scripts and configs  
✅ **Platform Support** - macOS, Ubuntu, Debian, Arch, Fedora  
✅ **Component Installation** - Shell, Development, Desktop, Fonts  
✅ **Theme Consistency** - Catppuccin Macchiato across all apps  
✅ **Configuration Linking** - Proper symlink management  
✅ **Idempotency** - Safe re-running of installations  
✅ **Error Handling** - Graceful failure scenarios  
✅ **Health Validation** - Post-installation verification  

This comprehensive testing approach ensures the dotfiles framework works reliably across all supported platforms and configurations.