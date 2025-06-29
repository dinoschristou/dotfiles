#!/bin/bash

# Git configuration installer

# Source utility functions
source "$(dirname "${BASH_SOURCE[0]}")/../utils/logger.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../utils/helpers.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../utils/prompts.sh"

# Prompt for git user configuration
prompt_git_config() {
    log_step "Configuring Git user settings..."
    
    local current_name current_email
    current_name=$(git config --global user.name 2>/dev/null || echo "")
    current_email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [[ -n "$current_name" ]] && [[ -n "$current_email" ]]; then
        log_info "Current Git configuration:"
        log_info "  Name: $current_name"
        log_info "  Email: $current_email"
        echo
        
        if ask_yes_no "Keep current Git configuration?" "y"; then
            log_success "Keeping existing Git configuration"
            return 0
        fi
    fi
    
    echo
    log_info "Setting up Git user configuration..."
    echo "This information will be used for your Git commits."
    echo
    
    local git_name git_email
    
    # Get user's full name
    while [[ -z "$git_name" ]]; do
        git_name=$(get_input "Enter your full name" "$current_name")
        if [[ -z "$git_name" ]]; then
            log_warn "Name cannot be empty. Please enter your full name."
        fi
    done
    
    # Get user's email
    while [[ -z "$git_email" ]]; do
        git_email=$(get_input "Enter your email address" "$current_email")
        if [[ -z "$git_email" ]]; then
            log_warn "Email cannot be empty. Please enter your email address."
        elif ! [[ "$git_email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
            log_warn "Invalid email format. Please enter a valid email address."
            git_email=""
        fi
    done
    
    # Configure Git
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    
    log_success "Git configuration updated:"
    log_success "  Name: $git_name"
    log_success "  Email: $git_email"
}

# Prompt for GitHub CLI login
prompt_github_cli_login() {
    if ! command_exists "gh"; then
        log_warn "GitHub CLI (gh) not found. Skipping GitHub authentication."
        return 0
    fi
    
    # Check if already logged in
    if gh auth status &>/dev/null; then
        local current_user
        current_user=$(gh auth status 2>&1 | grep "Logged in" | cut -d' ' -f6 || echo "unknown")
        log_success "Already logged in to GitHub as: $current_user"
        
        if ask_yes_no "Would you like to log out and log in with a different account?" "n"; then
            gh auth logout
        else
            return 0
        fi
    fi
    
    echo
    log_info "Setting up GitHub CLI authentication..."
    echo "This will allow you to interact with GitHub repositories from the command line."
    echo
    
    if ask_yes_no "Would you like to log in to GitHub now?" "y"; then
        log_info "Starting GitHub CLI authentication..."
        echo "Choose your preferred authentication method when prompted."
        echo
        
        # Run gh auth login
        if gh auth login; then
            log_success "Successfully authenticated with GitHub!"
            
            # Verify the login
            local username
            username=$(gh auth status 2>&1 | grep "Logged in" | cut -d' ' -f6 || echo "unknown")
            log_success "Logged in as: $username"
        else
            log_warn "GitHub authentication failed or was cancelled."
            log_info "You can run 'gh auth login' later to authenticate."
        fi
    else
        log_info "Skipping GitHub authentication."
        log_info "You can run 'gh auth login' later to authenticate."
    fi
}

# Install git configuration
install_git_configuration() {
    log_step "Installing Git configuration..."
    
    # Deploy git configuration files
    deploy_git_config
    
    # Prompt for user settings
    if [[ "$INTERACTIVE_MODE" == true ]]; then
        prompt_git_config
        prompt_github_cli_login
    fi
    
    log_success "Git configuration installed"
}

# Deploy git configuration files
deploy_git_config() {
    log_step "Deploying Git configuration files..."
    
    # Link gitconfig
    if [[ -f "$DOTFILES_DIR/gitconfig" ]]; then
        create_symlink "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
        log_success "Linked .gitconfig"
    else
        log_warn "gitconfig file not found in dotfiles"
    fi
    
    # Create git directories if they don't exist
    mkdir -p "$HOME/.config/git"
    
    # Link git ignore
    if [[ -f "$DOTFILES_DIR/gitignore" ]]; then
        create_symlink "$DOTFILES_DIR/gitignore" "$HOME/.config/git/ignore"
        log_success "Linked global gitignore"
    fi
    
    log_success "Git configuration files deployed"
}

# Validate git configuration
validate_git_config() {
    log_step "Validating Git configuration..."
    
    local errors=0
    
    # Check if git is installed
    if ! command_exists "git"; then
        log_error "Git is not installed"
        errors=$((errors + 1))
        return $errors
    fi
    
    # Check user configuration
    local git_name git_email
    git_name=$(git config --global user.name 2>/dev/null)
    git_email=$(git config --global user.email 2>/dev/null)
    
    if [[ -z "$git_name" ]]; then
        log_error "Git user.name is not configured"
        errors=$((errors + 1))
    else
        log_success "Git user.name: $git_name"
    fi
    
    if [[ -z "$git_email" ]]; then
        log_error "Git user.email is not configured"
        errors=$((errors + 1))
    else
        log_success "Git user.email: $git_email"
    fi
    
    # Check configuration files
    if [[ -L "$HOME/.gitconfig" ]]; then
        log_success "Git configuration properly symlinked"
    elif [[ -f "$HOME/.gitconfig" ]]; then
        log_warn "Git configuration exists but is not symlinked"
    else
        log_error "Git configuration file is missing"
        errors=$((errors + 1))
    fi
    
    return $errors
}