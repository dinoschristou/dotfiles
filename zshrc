autoload -Uz compinit
compinit

for file in ~/.{path,aliases}; do
  [ -r "$file" ] && source "$file"
done
unset file

# Bring in OS specific stuff
case $OSTYPE in
    darwin*)
      [ -r ~/.osx_shell ] && . ~/.osx_shell
    ;;
    linux*)
      [ -r ~/.linux_shell ] && . ~/.linux_shell
    ;;
esac


# History
setopt append_history
setopt extended_history
unsetopt hist_beep
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_no_store
setopt share_history
setopt inc_append_history
setopt hist_verify
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000


bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line

# Bring in work specific file if its there
[ -r ~/.work_shell ] && . ~/.work_shell

# Bring in host level overrides file if its there
[ -r ~/.host_shell ] && . ~/.host_shell

# Rust setup
[ -r ~/.cargo/env ] && . ~/.cargo/env

# Temporary prompt setup

# Colourful prompt
PROMPT='%(?.%F{green}√.%F{red}?%?)%f %B%F{240}%1~%f%b %# '

# Git status on right prompt
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats '%F{240}(%b)%r%f'
zstyle ':vcs_info:*' enable git

# Source powerlevel10k if it is available
[ -f ~/powerlevel10k/powerlevel10k.zsh-theme ] && . ~/powerlevel10k/powerlevel10k.zsh-theme

# Setup fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
