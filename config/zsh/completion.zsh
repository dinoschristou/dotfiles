# ZSH completion configuration

# Initialize completion system
autoload -Uz compinit
compinit

# 1Password completion
if [[ -t 1 ]] && command -v op &>/dev/null; then
  eval "$(op completion zsh)"
  compdef _op op
fi

# Homebrew completions
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  autoload -Uz compinit
  compinit
fi

# fzf integration
if type fzf &>/dev/null; then
  source <(fzf --zsh)
fi
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh