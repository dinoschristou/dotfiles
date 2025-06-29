#!/bin/bash

# Docker-based testing for dotfiles framework
# Tests installation on multiple Linux distributions

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Supported distributions for testing
DISTRIBUTIONS=(
    "ubuntu:22.04"
    "ubuntu:20.04"
    "debian:bullseye"
    "archlinux/archlinux:latest"
    "fedora:38"
)

# Test components to verify
TEST_COMPONENTS=(
    "shell"
    "neovim"
    "development"
)

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

# Create test Dockerfile for a distribution
create_test_dockerfile() {
    local distro="$1"
    local dockerfile_dir="$SCRIPT_DIR/dockerfiles"
    
    mkdir -p "$dockerfile_dir"
    
    local dockerfile="$dockerfile_dir/Dockerfile.${distro//[:.\/]/-}"
    
    cat > "$dockerfile" << EOF
FROM $distro

# Install basic dependencies
RUN if command -v apt-get >/dev/null 2>&1; then \\
        apt-get update && \\
        apt-get install -y sudo curl wget git ca-certificates unzip zip tar; \\
    elif command -v dnf >/dev/null 2>&1; then \\
        dnf update -y && \\
        dnf install -y sudo curl wget git ca-certificates unzip zip tar; \\
    elif command -v pacman >/dev/null 2>&1; then \\
        pacman -Sy --noconfirm sudo curl wget git ca-certificates unzip zip tar; \\
    fi

# Create test user
RUN useradd -m -s /bin/bash testuser && \\
    echo 'testuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set up working directory
WORKDIR /home/testuser
USER testuser

# Copy dotfiles
COPY --chown=testuser:testuser . /home/testuser/dotfiles/

# Set working directory to dotfiles
WORKDIR /home/testuser/dotfiles

# Default command
CMD ["/bin/bash"]
EOF

    echo "$dockerfile"
}

# Test installation on a specific distribution
test_distribution() {
    local distro="$1"
    local component="${2:-shell}"
    
    log_info "Testing $distro with $component component"
    
    # Create dockerfile
    local dockerfile
    dockerfile=$(create_test_dockerfile "$distro")
    
    # Build test image
    local image_name="dotfiles-test-${distro//[:.\/]/-}"
    
    log_info "Building test image for $distro..."
    if ! docker build -f "$dockerfile" -t "$image_name" "$DOTFILES_DIR" >/dev/null 2>&1; then
        log_error "Failed to build Docker image for $distro"
        return 1
    fi
    
    # Run dry-run test
    log_info "Running dry-run test for $distro..."
    if docker run --rm "$image_name" ./install.sh --$component --dry-run --non-interactive; then
        log_success "Dry-run test passed for $distro"
    else
        log_error "Dry-run test failed for $distro"
        return 1
    fi
    
    # Run validation test
    log_info "Running validation test for $distro..."
    if docker run --rm "$image_name" ./install.sh --test; then
        log_success "Validation test passed for $distro"
    else
        log_error "Validation test failed for $distro"
        return 1
    fi
    
    # Cleanup image
    docker rmi "$image_name" >/dev/null 2>&1 || true
    
    return 0
}

# Run tests on all distributions
test_all_distributions() {
    local component="${1:-shell}"
    local failed_tests=()
    local passed_tests=()
    
    log_info "Testing dotfiles installation across multiple distributions"
    log_info "Component: $component"
    echo
    
    for distro in "${DISTRIBUTIONS[@]}"; do
        if test_distribution "$distro" "$component"; then
            passed_tests+=("$distro")
        else
            failed_tests+=("$distro")
        fi
        echo
    done
    
    # Report results
    echo -e "${BLUE}===========================================${NC}"
    echo -e "${BLUE}              Test Results                 ${NC}"
    echo -e "${BLUE}===========================================${NC}"
    
    if [[ ${#passed_tests[@]} -gt 0 ]]; then
        echo -e "${GREEN}Passed distributions:${NC}"
        for distro in "${passed_tests[@]}"; do
            echo -e "  ✓ $distro"
        done
    fi
    
    if [[ ${#failed_tests[@]} -gt 0 ]]; then
        echo -e "${RED}Failed distributions:${NC}"
        for distro in "${failed_tests[@]}"; do
            echo -e "  ✗ $distro"
        done
        return 1
    fi
    
    log_success "All distribution tests passed!"
    return 0
}

# Test specific distribution interactively
test_interactive() {
    local distro="$1"
    
    if [[ -z "$distro" ]]; then
        log_error "Please specify a distribution to test"
        echo "Available distributions:"
        for d in "${DISTRIBUTIONS[@]}"; do
            echo "  - $d"
        done
        exit 1
    fi
    
    log_info "Starting interactive test environment for $distro"
    
    # Create dockerfile
    local dockerfile
    dockerfile=$(create_test_dockerfile "$distro")
    
    # Build test image
    local image_name="dotfiles-test-${distro//[:.\/]/-}"
    
    log_info "Building test image..."
    docker build -f "$dockerfile" -t "$image_name" "$DOTFILES_DIR"
    
    log_info "Starting interactive shell..."
    docker run -it --rm "$image_name" /bin/bash
    
    # Cleanup
    docker rmi "$image_name" >/dev/null 2>&1 || true
}

# Show usage
show_usage() {
    cat << EOF
Docker-based testing for dotfiles framework

USAGE:
    $0 [OPTIONS] [COMMAND]

COMMANDS:
    all [component]         Test all distributions (default: shell)
    interactive <distro>    Start interactive test session
    list                    List available distributions

OPTIONS:
    -h, --help             Show this help message

EXAMPLES:
    $0 all shell           # Test shell component on all distributions
    $0 all development     # Test development component on all distributions
    $0 interactive ubuntu:22.04  # Interactive test on Ubuntu 22.04
    $0 list                # Show available distributions

REQUIREMENTS:
    - Docker must be installed and running
    - Current user must have Docker permissions

EOF
}

# Check if Docker is available
check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        log_error "Docker is not installed"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker is not running or you don't have permission to use it"
        exit 1
    fi
}

# Main function
main() {
    check_docker
    
    case "${1:-all}" in
        "all")
            test_all_distributions "${2:-shell}"
            ;;
        "interactive")
            test_interactive "$2"
            ;;
        "list")
            echo "Available distributions:"
            for distro in "${DISTRIBUTIONS[@]}"; do
                echo "  - $distro"
            done
            ;;
        "-h"|"--help")
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