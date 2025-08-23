# Modern ZSH Configuration
# This configuration is modular and organized into logical sections

# XDG Base Directory specification compliance
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# ZSH configuration directory
ZSH_CONFIG_DIR="$XDG_CONFIG_HOME/zsh"

# Load modular configuration files
source_if_exists() {
    [[ -r "$1" ]] && source "$1"
}

# Core ZSH configuration
source_if_exists "$ZSH_CONFIG_DIR/history.zsh"
source_if_exists "$ZSH_CONFIG_DIR/keybindings.zsh"
source_if_exists "$ZSH_CONFIG_DIR/completion.zsh"

# Environment and platform setup
source_if_exists "$ZSH_CONFIG_DIR/environment.zsh"
source_if_exists "$ZSH_CONFIG_DIR/platform.zsh"

# UI and aliases
source_if_exists "$ZSH_CONFIG_DIR/prompt.zsh"
source_if_exists "$ZSH_CONFIG_DIR/aliases.zsh"

# User-specific overrides (maintain backward compatibility)
source_if_exists ~/.work_shell      # Work-specific customizations
source_if_exists ~/.host_shell      # Host-specific customizations
source_if_exists ~/.env             # Mostly API Keys

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/dinos/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/dinos/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/dinos/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/dinos/google-cloud-sdk/completion.zsh.inc'; fi

