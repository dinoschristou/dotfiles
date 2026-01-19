# Environment variables and path configuration

# Base PATH setup
PATH=/usr/local/bin:$PATH
PATH=$HOME/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"

# Go development
PATH=/usr/local/go/bin:$PATH
export PATH="~/go/bin:$PATH"

# Infrastructure environment variables
export SOPS_AGE_KEY_FILE=$HOME/.sops/key.txt
export KUBECONFIG=~/.kube/config

# Rust environment
[ -r ~/.cargo/env ] && . ~/.cargo/env

# GCP SDK
[ -f ~/bin/google-cloud-sdk/path.zsh.inc ] && . ~/bin/google-cloud-sdk/path.zsh.inc
[ -f ~/bin/google-cloud-sdk/completion.zsh.inc ] && . ~/bin/google-cloud-sdk/completion.zsh.inc