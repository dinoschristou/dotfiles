#!/bin/bash

# Development tools installer

install_development_tools() {
    log_step "Installing development tools"

    # Install programming languages
    install_programming_languages

    # Install cloud tools
    install_cloud_tools

    # Install development utilities
    install_development_utilities

    # Configure Git
    configure_git

    log_success "Development tools installed successfully"
}

install_programming_languages() {
    log_info "Installing programming languages..."

    # Install Go
    install_go

    # Install Rust
    install_rust

    # Install Node.js via fnm
    install_nodejs_via_fnm

    # Install Python tools
    install_python_tools
}

install_go() {
    if ! command_exists "go"; then
        log_info "Installing Go..."
        
        case "$OS_NAME" in
            "Darwin")
                brew install go
                ;;
            "Ubuntu"|"Debian"|"Fedora")
                # Install Go from official source for latest version
                local go_version="1.21.5"
                local go_arch="amd64"
                [[ "$ARCH" == "arm64" ]] && go_arch="arm64"
                
                log_info "Downloading Go $go_version..."
                wget -q "https://go.dev/dl/go${go_version}.linux-${go_arch}.tar.gz" -O "/tmp/go.tar.gz"
                
                # Remove existing Go installation
                sudo rm -rf /usr/local/go
                
                # Extract new version
                sudo tar -C /usr/local -xzf "/tmp/go.tar.gz"
                rm -f "/tmp/go.tar.gz"
                
                log_success "Go $go_version installed"
                ;;
            "Arch")
                sudo pacman -S --noconfirm go
                ;;
        esac
    else
        local go_version
        go_version=$(go version 2>/dev/null | cut -d' ' -f3)
        log_debug "Go already installed: $go_version"
    fi
}

install_rust() {
    if ! command_exists "rustc"; then
        log_info "Installing Rust..."
        
        # Install via rustup
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
        
        # Source cargo environment
        source "$HOME/.cargo/env" 2>/dev/null || true
        
        log_success "Rust installed via rustup"
    else
        local rust_version
        rust_version=$(rustc --version 2>/dev/null)
        log_debug "Rust already installed: $rust_version"
    fi
}

install_nodejs_via_fnm() {
    if ! command_exists "fnm"; then
        log_info "Installing fnm (Fast Node Manager)..."
        
        # Install fnm
        curl -fsSL https://fnm.vercel.app/install | bash --skip-shell
        
        # Source fnm
        export PATH="$HOME/.local/share/fnm:$PATH"
        eval "$(fnm env --use-on-cd 2>/dev/null || true)"
        
        # Install latest LTS Node.js
        if command_exists "fnm"; then
            log_info "Installing Node.js LTS via fnm..."
            fnm install --lts
            fnm use lts-latest
            fnm default lts-latest
            log_success "Node.js LTS installed via fnm"
        fi
    else
        log_debug "fnm already installed"
    fi
}

install_python_tools() {
    log_info "Installing Python development tools..."
    
    # Install pip if not available
    if ! command_exists "pip3" && ! command_exists "pip"; then
        case "$OS_NAME" in
            "Darwin")
                # Python3 and pip should be available via Xcode tools
                log_debug "Python tools available via system"
                ;;
            "Ubuntu"|"Debian")
                sudo apt-get install -y python3-pip python3-venv
                ;;
            "Arch")
                sudo pacman -S --noconfirm python-pip
                ;;
            "Fedora")
                sudo dnf install -y python3-pip python3-venv
                ;;
        esac
    fi
    
    # Install common Python tools
    if command_exists "pip3"; then
        log_info "Installing Python development tools..."
        pip3 install --user --upgrade pip setuptools wheel
        pip3 install --user black isort flake8 mypy
        
        # Install uv - modern Python package manager
        log_info "Installing uv Python package manager..."
        pip3 install --user uv
    fi
}

install_cloud_tools() {
    log_info "Installing cloud and infrastructure tools..."

    # Install Docker
    install_docker

    # Install kubectl
    install_kubectl

    # Install Helm
    install_helm

    # Install Terraform
    install_terraform

    # Install cloud CLIs
    install_cloud_clis
}

install_docker() {
    if ! command_exists "docker"; then
        log_info "Installing Docker..."
        
        case "$OS_NAME" in
            "Darwin")
                log_info "Please install Docker Desktop for Mac manually"
                log_info "Download from: https://www.docker.com/products/docker-desktop"
                ;;
            "Ubuntu"|"Debian")
                # Install Docker via official repository
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                sudo apt-get update
                sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
                
                # Add user to docker group
                sudo usermod -aG docker "$USER"
                log_info "Please log out and back in for Docker group membership to take effect"
                ;;
            "Arch")
                sudo pacman -S --noconfirm docker docker-compose
                sudo systemctl enable docker
                sudo usermod -aG docker "$USER"
                ;;
            "Fedora")
                sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
                sudo systemctl enable docker
                sudo usermod -aG docker "$USER"
                ;;
        esac
    else
        log_debug "Docker already installed"
    fi
}

install_kubectl() {
    if ! command_exists "kubectl"; then
        log_info "Installing kubectl..."
        
        case "$OS_NAME" in
            "Darwin")
                brew install kubernetes-cli
                ;;
            *)
                # Install latest stable version
                curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                chmod +x kubectl
                sudo mv kubectl /usr/local/bin/
                ;;
        esac
        
        log_success "kubectl installed"
    else
        log_debug "kubectl already installed"
    fi
}

install_helm() {
    if ! command_exists "helm"; then
        log_info "Installing Helm..."
        
        case "$OS_NAME" in
            "Darwin")
                brew install helm
                ;;
            *)
                curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
                ;;
        esac
        
        log_success "Helm installed"
    else
        log_debug "Helm already installed"
    fi
}

install_terraform() {
    if ! command_exists "terraform"; then
        log_info "Installing Terraform..."
        
        case "$OS_NAME" in
            "Darwin")
                brew tap hashicorp/tap
                brew install hashicorp/tap/terraform
                ;;
            "Ubuntu"|"Debian")
                wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
                echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
                sudo apt-get update && sudo apt-get install -y terraform
                ;;
            "Arch")
                yay -S --noconfirm terraform
                ;;
            "Fedora")
                sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
                sudo dnf install -y terraform
                ;;
        esac
        
        log_success "Terraform installed"
    else
        log_debug "Terraform already installed"
    fi
}

install_cloud_clis() {
    # Install Google Cloud SDK
    if ! command_exists "gcloud"; then
        log_info "Installing Google Cloud SDK..."
        case "$OS_NAME" in
            "Darwin")
                brew install google-cloud-sdk
                ;;
            *)
                curl https://sdk.cloud.google.com | bash
                ;;
        esac
    fi

    # Note: AWS CLI and Azure CLI can be added here if needed
}

install_development_utilities() {
    log_info "Installing development utilities..."

    # Git-related tools
    install_git_tools

    # Database tools
    install_database_tools
}

install_git_tools() {
    # git-delta for better diff output
    if ! command_exists "delta"; then
        case "$OS_NAME" in
            "Darwin")
                brew install git-delta
                ;;
            "Ubuntu"|"Debian")
                # Install from GitHub releases
                local delta_version="0.16.5"
                wget -q "https://github.com/dandavison/delta/releases/download/${delta_version}/git-delta_${delta_version}_amd64.deb" -O "/tmp/git-delta.deb"
                sudo dpkg -i "/tmp/git-delta.deb" || sudo apt-get install -f -y
                rm -f "/tmp/git-delta.deb"
                ;;
            "Arch")
                sudo pacman -S --noconfirm git-delta
                ;;
            "Fedora")
                sudo dnf install -y git-delta
                ;;
        esac
    fi
}

install_database_tools() {
    # Add database tools if needed
    log_debug "Database tools installation placeholder"
}

configure_git() {
    log_info "Configuring Git..."

    # Deploy git configuration
    create_symlink "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"

    log_success "Git configuration deployed"
}