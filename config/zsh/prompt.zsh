# ZSH prompt configuration

# BACKUP prompt when powerlevel10k is not available
PROMPT='%(?.%F{green}√.%F{red}?%?)%f %B%F{240}%1~%f%b %# '

# Git status on right prompt
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats '%F{240}(%b)%r%f'
zstyle ':vcs_info:*' enable git

# Source Powerlevel10k if it is available
[ -f "$HOME/powerlevel10k/powerlevel10k.zsh-theme" ] && source "$HOME/powerlevel10k/powerlevel10k.zsh-theme"
[ -f "$HOME/.zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme" ] && source "$HOME/.zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Stub for work-specific version control prompt
prompt_yasc() {}