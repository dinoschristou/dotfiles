#!/bin/bash

# Health check script

run_health_check() {
    log_header "Running System Health Check"

    local errors=0
    local warnings=0

    # Check shell configuration
    errors=$((errors + $(check_shell_config)))

    # Check git configuration
    errors=$((errors + $(check_git_config)))

    # Check development tools
    errors=$((errors + $(check_development_tools)))

    # Check desktop environment (Linux only)
    if [[ "$OS_TYPE" == "Linux" ]]; then
        errors=$((errors + $(check_desktop_environment)))
    fi

    # Check configuration files
    errors=$((errors + $(check_configuration_files)))

    # Check fonts
    warnings=$((warnings + $(check_fonts)))

    # Summary
    show_health_summary $errors $warnings

    return $errors
}

check_shell_config() {
    log_step "Checking shell configuration..."
    local errors=0

    # Check if zsh is available
    if ! command_exists "zsh"; then
        log_error "zsh is not installed"
        errors=$((errors + 1))
    else
        log_success "zsh is installed"
        
        # Check zsh version
        local zsh_version
        zsh_version=$(zsh --version 2>/dev/null | cut -d' ' -f2)
        log_info "zsh version: $zsh_version"
    fi

    # Check shell configuration files
    local shell_configs=(
        "$HOME/.zshrc"
        "$HOME/.p10k.zsh"
    )

    for config in "${shell_configs[@]}"; do
        if [[ -L "$config" ]]; then
            log_success "✓ $config (symlinked)"
        elif [[ -f "$config" ]]; then
            log_warn "⚠ $config exists but is not symlinked"
        else
            log_error "✗ $config is missing"
            errors=$((errors + 1))
        fi
    done

    # Test zsh configuration
    if [[ -f "$HOME/.zshrc" ]]; then
        if zsh -c "source ~/.zshrc && echo 'Shell configuration OK'" 2>/dev/null | grep -q "OK"; then
            log_success "zsh configuration loads successfully"
        else
            log_error "zsh configuration has errors"
            errors=$((errors + 1))
        fi
    fi

    # Check shell plugins
    check_shell_plugins

    return $errors
}

check_shell_plugins() {
    log_info "Checking shell plugins..."

    case "$OS_NAME" in
        "Darwin")
            # Check Homebrew-installed plugins
            if brew list zsh-autosuggestions &>/dev/null; then
                log_success "zsh-autosuggestions installed"
            else
                log_warn "zsh-autosuggestions not found"
            fi

            if brew list zsh-fast-syntax-highlighting &>/dev/null; then
                log_success "zsh-fast-syntax-highlighting installed"
            else
                log_warn "zsh-fast-syntax-highlighting not found"
            fi
            ;;
        *)
            # Check package manager installed plugins
            local plugin_paths=(
                "/usr/share/zsh-autosuggestions"
                "/usr/share/zsh-syntax-highlighting"
                "/usr/share/zsh/plugins/zsh-autosuggestions"
                "/usr/share/zsh/plugins/zsh-syntax-highlighting"
            )

            local plugins_found=false
            for path in "${plugin_paths[@]}"; do
                if [[ -d "$path" ]]; then
                    log_success "Shell plugins found at $path"
                    plugins_found=true
                    break
                fi
            done

            if [[ "$plugins_found" == false ]]; then
                log_warn "Shell plugins not found in standard locations"
            fi
            ;;
    esac
}

check_git_config() {
    log_step "Checking Git configuration..."
    local errors=0

    # Check if git is installed
    if ! command_exists "git"; then
        log_error "Git is not installed"
        errors=$((errors + 1))
        return $errors
    else
        local git_version
        git_version=$(git --version 2>/dev/null | cut -d' ' -f3)
        log_success "✓ git ($git_version)"
    fi

    # Check user configuration
    local git_name git_email
    git_name=$(git config --global user.name 2>/dev/null)
    git_email=$(git config --global user.email 2>/dev/null)

    if [[ -z "$git_name" ]]; then
        log_error "✗ Git user.name is not configured"
        errors=$((errors + 1))
    else
        log_success "✓ Git user.name: $git_name"
    fi

    if [[ -z "$git_email" ]]; then
        log_error "✗ Git user.email is not configured"
        errors=$((errors + 1))
    else
        log_success "✓ Git user.email: $git_email"
    fi

    # Check configuration files
    if [[ -L "$HOME/.gitconfig" ]]; then
        log_success "✓ Git configuration properly symlinked"
    elif [[ -f "$HOME/.gitconfig" ]]; then
        log_warn "⚠ Git configuration exists but is not symlinked"
    else
        log_error "✗ Git configuration file is missing"
        errors=$((errors + 1))
    fi

    return $errors
}

check_development_tools() {
    log_step "Checking development tools..."
    local errors=0

    # Essential development tools
    local dev_tools=(
        "git:Git version control"
        "nvim:Neovim editor"
        "vim:Vim editor"
        "tmux:Terminal multiplexer"
        "fzf:Fuzzy finder"
        "rg:Ripgrep search tool"
        "fd:Modern find replacement"
        "bat:Enhanced cat with syntax highlighting"
        "btop:Modern system monitor"
        "fastfetch:Modern system info tool"
        "lazygit:Terminal Git UI"
        "tailscale:VPN mesh networking"
        "gh:GitHub CLI"
        "zoxide:Smart directory jumper"
        "ansible:Configuration management"
        "hugo:Static site generator"
        "pre-commit:Git pre-commit hooks"
        "docker:Container platform"
    )

    for tool_info in "${dev_tools[@]}"; do
        local tool="${tool_info%%:*}"
        local description="${tool_info##*:}"
        
        if command_exists "$tool"; then
            local version
            case "$tool" in
                "git")
                    version=$(git --version 2>/dev/null | cut -d' ' -f3)
                    ;;
                "nvim")
                    version=$(nvim --version 2>/dev/null | head -n1 | cut -d' ' -f2)
                    ;;
                "tmux")
                    version=$(tmux -V 2>/dev/null | cut -d' ' -f2)
                    ;;
                *)
                    version=$($tool --version 2>/dev/null | head -n1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -n1)
                    ;;
            esac
            log_success "✓ $tool ($description) - $version"
        else
            log_error "✗ $tool ($description) not found"
            errors=$((errors + 1))
        fi
    done

    # Check programming languages
    check_programming_languages

    # Check Neovim configuration
    if command_exists "nvim"; then
        check_neovim_health
    fi

    return $errors
}

check_programming_languages() {
    log_info "Checking programming languages..."

    local languages=(
        "go:Go programming language"
        "rustc:Rust compiler"
        "node:Node.js runtime"
        "python3:Python 3 interpreter"
    )

    for lang_info in "${languages[@]}"; do
        local lang="${lang_info%%:*}"
        local description="${lang_info##*:}"
        
        if command_exists "$lang"; then
            local version
            case "$lang" in
                "go")
                    version=$(go version 2>/dev/null | cut -d' ' -f3)
                    ;;
                "rustc")
                    version=$(rustc --version 2>/dev/null | cut -d' ' -f2)
                    ;;
                "node")
                    version=$(node --version 2>/dev/null)
                    ;;
                "python3")
                    version=$(python3 --version 2>/dev/null | cut -d' ' -f2)
                    ;;
            esac
            log_success "✓ $lang ($description) - $version"
        else
            log_warn "⚠ $lang ($description) not found"
        fi
    done
}

check_neovim_health() {
    log_info "Checking Neovim health..."

    # Run Neovim health check
    local health_output
    health_output=$(nvim --headless -c "checkhealth" -c "qa" 2>&1)

    if echo "$health_output" | grep -qi "error"; then
        log_warn "Neovim health check found errors"
        log_info "Run ':checkhealth' in Neovim for details"
    else
        log_success "Neovim health check passed"
    fi

    # Check for lazy.nvim
    if [[ -d "$HOME/.local/share/nvim/lazy" ]]; then
        log_success "lazy.nvim package manager found"
    else
        log_warn "lazy.nvim package manager not found"
    fi
}

check_desktop_environment() {
    log_step "Checking desktop environment (Linux)..."
    local errors=0

    # Check window managers
    local window_managers=(
        "hyprland:Hyprland compositor"
        "hyprlock:Hyprland lock screen"
        "hypridle:Hyprland idle daemon"
        "sway:Sway compositor"
    )

    local wm_found=false
    for wm_info in "${window_managers[@]}"; do
        local wm="${wm_info%%:*}"
        local description="${wm_info##*:}"
        
        if command_exists "$wm"; then
            log_success "✓ $wm ($description) available"
            wm_found=true
        fi
    done

    if [[ "$wm_found" == false ]]; then
        log_error "No supported window managers found"
        errors=$((errors + 1))
    fi

    # Check supporting tools
    local desktop_tools=(
        "waybar:Status bar"
        "wofi:Application launcher"
        "mako:Notification daemon"
        "kitty:Terminal emulator"
        "grim:Screenshot tool"
        "slurp:Area selection tool"
        "swaybg:Wallpaper daemon"
        "imv:Image viewer"
        "blueberry:Bluetooth manager"
        "xournalpp:Note-taking app"
        "typora:Markdown editor"
    )

    for tool_info in "${desktop_tools[@]}"; do
        local tool="${tool_info%%:*}"
        local description="${tool_info##*:}"
        
        if command_exists "$tool"; then
            log_success "✓ $tool ($description)"
        else
            log_warn "⚠ $tool ($description) not found"
        fi
    done

    # Check display server
    if [[ -n "$WAYLAND_DISPLAY" ]]; then
        log_success "Running on Wayland"
    elif [[ -n "$DISPLAY" ]]; then
        log_info "Running on X11"
    else
        log_warn "No display server detected"
    fi

    return $errors
}

check_configuration_files() {
    log_step "Checking configuration files..."
    local errors=0

    # Define configuration files to check
    local configs=(
        "$DOTFILES_DIR/zshrc:$HOME/.zshrc"
        "$DOTFILES_DIR/gitconfig:$HOME/.gitconfig"
        "$DOTFILES_DIR/config/nvim:$HOME/.config/nvim"
        "$DOTFILES_DIR/config/kitty:$HOME/.config/kitty"
    )

    # Add Linux-specific configs
    if [[ "$OS_TYPE" == "Linux" ]]; then
        configs+=(
            "$DOTFILES_DIR/config/hypr:$HOME/.config/hypr"
            "$DOTFILES_DIR/config/waybar:$HOME/.config/waybar"
            "$DOTFILES_DIR/config/wofi:$HOME/.config/wofi"
            "$DOTFILES_DIR/config/mako:$HOME/.config/mako"
            "$DOTFILES_DIR/config/btop:$HOME/.config/btop"
        )
    fi

    for config_pair in "${configs[@]}"; do
        local source="${config_pair%%:*}"
        local target="${config_pair##*:}"
        
        if [[ ! -e "$source" ]]; then
            log_warn "Source configuration missing: $source"
            continue
        fi

        if [[ -L "$target" ]]; then
            local link_target
            link_target=$(readlink "$target")
            if [[ "$link_target" == "$source" ]]; then
                log_success "✓ $target correctly symlinked"
            else
                log_warn "⚠ $target symlinked to wrong location: $link_target"
            fi
        elif [[ -e "$target" ]]; then
            log_warn "⚠ $target exists but is not symlinked"
        else
            log_error "✗ $target is missing"
            errors=$((errors + 1))
        fi
    done

    return $errors
}

check_fonts() {
    log_step "Checking fonts..."
    local warnings=0

    local required_fonts=(
        "FiraCode"
        "JetBrains"
        "Hack"
    )

    case "$OS_NAME" in
        "Darwin")
            for font in "${required_fonts[@]}"; do
                if system_profiler SPFontsDataType 2>/dev/null | grep -q "$font"; then
                    log_success "✓ $font font family found"
                else
                    log_warn "⚠ $font font family not found"
                    warnings=$((warnings + 1))
                fi
            done
            ;;
        *)
            if command_exists "fc-list"; then
                for font in "${required_fonts[@]}"; do
                    if fc-list 2>/dev/null | grep -qi "$font"; then
                        log_success "✓ $font font family found"
                    else
                        log_warn "⚠ $font font family not found"
                        warnings=$((warnings + 1))
                    fi
                done
            else
                log_warn "fc-list not available, cannot check fonts"
                warnings=$((warnings + 1))
            fi
            ;;
    esac

    return $warnings
}

show_health_summary() {
    local errors=$1
    local warnings=$2

    log_header "Health Check Summary"

    if [[ $errors -eq 0 ]] && [[ $warnings -eq 0 ]]; then
        log_success "🎉 All checks passed! Your dotfiles installation is healthy."
    elif [[ $errors -eq 0 ]]; then
        log_warn "⚠ Installation mostly healthy with $warnings warning(s)"
        log_info "Consider addressing warnings for optimal experience"
    else
        log_error "❌ Found $errors error(s) and $warnings warning(s)"
        log_info "Please address errors before continuing"
    fi

    echo
    log_info "For detailed troubleshooting, check individual component logs above"
    
    if [[ "$OS_TYPE" == "Linux" ]]; then
        log_info "Desktop environment: Use 'journalctl -xe' for system logs"
    fi
    
    log_info "Neovim: Run ':checkhealth' for detailed plugin status"
    log_info "Shell: Test with 'zsh -c \"source ~/.zshrc\"'"
}