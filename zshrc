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

# Bring in work specific file if its there
[ -r ~/.work_shell ] && . ~/.work_shell

# Bring in host level overrides file if its there
[ -r ~/.host_shell ] && . ~/.host_shell

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
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
