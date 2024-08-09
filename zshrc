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
      alias tailscale=/Applications/Tailscale.app/Contents/MacOS/Tailscale

      # Homebrew
      eval "$(/opt/homebrew/bin/brew shellenv)"
      export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"
      export PATH="/opt/homebrew/opt/openssl@1.1/bin:$PATH"
      [[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"

      # iterm config
      [ -f ~/.iterm2_shell_integration.zsh ] && . ~/.iterm2_shell_integration.zsh
    ;;
    linux*)
      [ -r ~/.linux_shell ] && . ~/.linux_shell
    ;;
esac

# Go bits
export PATH="~/go/bin:$PATH"

# Homeserver stuff 
export SOPS_AGE_KEY_FILE=$HOME/.sops/key.txt
export KUBECONFIG=~/.kube/config
alias promload2="curl -L -X POST prometheus.dr.knxcloud.io/-/reload"

# The next line updates PATH for the Google Cloud SDK.
[ -f ~/bin/google-cloud-sdk/path.zsh.inc ] && . ~/bin/google-cloud-sdk/path.zsh.inc
[ -f ~/bin/google-cloud-sdk/completion.zsh.inc ] && . ~/bin/google-cloud-sdk/completion.zsh.inc

# History
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.
setopt APPEND_HISTORY            # append to history file (Default)
setopt HIST_NO_STORE             # Don't store history commands
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks from each command line being added to the history list.
setopt hist_expire_dups_first
unsetopt hist_beep

HISTFILE=~/.zsh_history
HISTSIZE=500000
SAVEHIST=500000
HISTORY_IGNORE="(ls|cd|pwd|exit|cd)*"
HIST_STAMPS="yyyy-mm-dd"


bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line

# Stub for any work specific sc I use at this point in time
# yet another source control
prompt_yasc()

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

# zsh autosuggestions - depends where I remembered to put it
[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ] && . ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source ~/powerlevel10k/powerlevel10k.zsh-theme

# 1password
if type op &>/dev/null
then
  eval "$(op completion zsh)"
  compdef _op op
fi

if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit
fi