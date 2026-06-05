# Environment variables and path configuration

# Base PATH setup
PATH=/usr/local/bin:$PATH
PATH=$HOME/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"

# Go development
PATH=/usr/local/go/bin:$PATH
export PATH="~/go/bin:$PATH"

# Antigravity CLI
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.antigravity-ide/antigravity-ide/bin:$PATH"

# Obsidian CLI
export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"

# Infrastructure environment variables
export SOPS_AGE_KEY_FILE=$HOME/.sops/key.txt
export KUBECONFIG=$HOME/.kube/config

# Rust environment
[ -r $HOME/.cargo/env ] && . $HOME/.cargo/env

# GCP SDK
[ -f $HOME/bin/google-cloud-sdk/path.zsh.inc ] && . $HOME/bin/google-cloud-sdk/path.zsh.inc
[ -f $HOME/bin/google-cloud-sdk/completion.zsh.inc ] && . $HOME/bin/google-cloud-sdk/completion.zsh.inc
