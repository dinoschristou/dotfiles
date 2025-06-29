#!/bin/bash

# Validation test suite for dotfiles framework
# Tests syntax, YAML validity, and basic configuration checks

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

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test result tracking
FAILED_TESTS=()

# Helper functions
log_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
    TESTS_RUN=$((TESTS_RUN + 1))
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_TESTS+=("$1")
}

log_skip() {
    echo -e "${YELLOW}[SKIP]${NC} $1"
}

# Test bash script syntax
test_bash_syntax() {
    log_test "Testing Bash script syntax"
    
    local failed_scripts=()
    
    # Find all .sh files
    while IFS= read -r -d '' script; do
        if ! bash -n "$script" 2>/dev/null; then
            failed_scripts+=("$script")
        fi
    done < <(find "$DOTFILES_DIR" -name "*.sh" -type f -print0)
    
    if [[ ${#failed_scripts[@]} -eq 0 ]]; then
        log_pass "All Bash scripts have valid syntax"
    else
        log_fail "Bash syntax errors in: ${failed_scripts[*]}"
    fi
}

# Test YAML validity
test_yaml_syntax() {
    log_test "Testing YAML configuration syntax"
    
    local failed_yamls=()
    
    # Check if yq is available
    if ! command -v yq >/dev/null 2>&1; then
        log_skip "yq not available, skipping YAML validation"
        return
    fi
    
    # Find all .yaml and .yml files
    while IFS= read -r -d '' yaml_file; do
        if ! yq eval . "$yaml_file" >/dev/null 2>&1; then
            failed_yamls+=("$yaml_file")
        fi
    done < <(find "$DOTFILES_DIR" -name "*.yaml" -o -name "*.yml" -type f -print0)
    
    if [[ ${#failed_yamls[@]} -eq 0 ]]; then
        log_pass "All YAML files have valid syntax"
    else
        log_fail "YAML syntax errors in: ${failed_yamls[*]}"
    fi
}

# Test required files exist
test_required_files() {
    log_test "Testing required files exist"
    
    local required_files=(
        "install.sh"
        "zshrc"
        "config/kitty/kitty.conf"
        "config/nvim/init.lua"
        "scripts/utils/logger.sh"
        "scripts/utils/helpers.sh"
        "scripts/utils/package-manager.sh"
        "scripts/packages/config/essential.yaml"
        "scripts/packages/config/development.yaml"
        "scripts/packages/config/desktop.yaml"
    )
    
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$DOTFILES_DIR/$file" ]]; then
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -eq 0 ]]; then
        log_pass "All required files exist"
    else
        log_fail "Missing required files: ${missing_files[*]}"
    fi
}

# Test configuration integrity
test_config_integrity() {
    log_test "Testing configuration file integrity"
    
    local errors=()
    
    # Test Catppuccin theme consistency
    local catppuccin_files=(
        "config/kitty/current-theme.conf"
        "config/lazygit/config.yml"
        "config/fastfetch/config.jsonc"
        "config/sway/catppuccin-macchiato.conf"
        "tmux.conf"
    )
    
    for file in "${catppuccin_files[@]}"; do
        if [[ -f "$DOTFILES_DIR/$file" ]]; then
            # Check for Catppuccin Macchiato colors (case-insensitive)
            if ! grep -qi "#24273a\|#cad3f5\|#8aadf4" "$DOTFILES_DIR/$file" 2>/dev/null; then
                errors+=("$file: Missing Catppuccin Macchiato colors")
            fi
        fi
    done
    
    # Test package configuration completeness
    if command -v yq >/dev/null 2>&1; then
        local package_configs=("essential.yaml" "development.yaml" "desktop.yaml")
        
        for config in "${package_configs[@]}"; do
            local config_file="$DOTFILES_DIR/scripts/packages/config/$config"
            if [[ -f "$config_file" ]]; then
                # Check if config has at least one package
                local package_count=$(yq eval 'keys | length' "$config_file" 2>/dev/null || echo "0")
                if [[ "$package_count" -eq 0 ]]; then
                    errors+=("$config: No packages defined")
                fi
            fi
        done
    fi
    
    if [[ ${#errors[@]} -eq 0 ]]; then
        log_pass "Configuration integrity checks passed"
    else
        for error in "${errors[@]}"; do
            log_fail "Config integrity: $error"
        done
    fi
}

# Test symlink targets
test_symlink_targets() {
    log_test "Testing symlink target validity"
    
    local broken_links=()
    
    # Find all symlinks and check if their targets exist
    while IFS= read -r -d '' link; do
        if [[ -L "$link" ]] && [[ ! -e "$link" ]]; then
            broken_links+=("$link")
        fi
    done < <(find "$DOTFILES_DIR" -type l -print0 2>/dev/null)
    
    if [[ ${#broken_links[@]} -eq 0 ]]; then
        log_pass "All symlinks have valid targets"
    else
        log_fail "Broken symlinks found: ${broken_links[*]}"
    fi
}

# Test install script argument parsing
test_install_args() {
    log_test "Testing install script argument parsing"
    
    local install_script="$DOTFILES_DIR/install.sh"
    
    if [[ ! -f "$install_script" ]]; then
        log_fail "Install script not found"
        return
    fi
    
    # Test help output
    if bash "$install_script" --help >/dev/null 2>&1; then
        log_pass "Install script help works"
    else
        log_fail "Install script help failed"
    fi
    
    # Test that install script doesn't run with invalid args
    if ! bash "$install_script" --invalid-argument >/dev/null 2>&1; then
        log_pass "Install script rejects invalid arguments"
    else
        log_fail "Install script accepts invalid arguments"
    fi
}

# Main test runner
main() {
    echo -e "${BLUE}===========================================${NC}"
    echo -e "${BLUE}      Dotfiles Framework Validation       ${NC}"
    echo -e "${BLUE}===========================================${NC}"
    echo
    
    cd "$DOTFILES_DIR"
    
    # Run all tests
    test_bash_syntax
    test_yaml_syntax
    test_required_files
    test_config_integrity
    test_symlink_targets
    test_install_args
    
    echo
    echo -e "${BLUE}===========================================${NC}"
    echo -e "${BLUE}              Test Results                 ${NC}"
    echo -e "${BLUE}===========================================${NC}"
    echo -e "Tests run: ${TESTS_RUN}"
    echo -e "${GREEN}Passed: ${TESTS_PASSED}${NC}"
    echo -e "${RED}Failed: ${TESTS_FAILED}${NC}"
    
    if [[ ${#FAILED_TESTS[@]} -gt 0 ]]; then
        echo
        echo -e "${RED}Failed tests:${NC}"
        for test in "${FAILED_TESTS[@]}"; do
            echo -e "  - $test"
        done
        
        exit 1
    else
        echo
        echo -e "${GREEN}All tests passed! 🎉${NC}"
        exit 0
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi