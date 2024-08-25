################################################################################################
## Autocompletion
################################################################################################
autoload -Uz compinit
compinit
################################################################################################
## End of Autocompletion
################################################################################################

################################################################################################
## Bring in OS specific stuff
################################################################################################
case $OSTYPE in
    darwin*)
      alias tailscale=/Applications/Tailscale.app/Contents/MacOS/Tailscale

      # Homebrew
      eval "$(/opt/homebrew/bin/brew shellenv)"
      export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"
      export PATH="/opt/homebrew/opt/openssl@1.1/bin:$PATH"
      [[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"

      [ -r /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && . '/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh'
      [ -r /opt/homebrew/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ] && . '/opt/homebrew/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh'
      
      # iterm config
      [ -f ~/.iterm2_shell_integration.zsh ] && . ~/.iterm2_shell_integration.zsh
    ;;
    linux*)
      [ -r ~/.linux_shell ] && . ~/.linux_shell

      [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      [ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ] && . ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
    ;;
esac
################################################################################################
## End of OS specific stuff
################################################################################################

################################################################################################
## Path Setup
################################################################################################
PATH=/usr/local/bin:$PATH
PATH=$HOME/bin:$PATH
################################################################################################
## End of Path Setup
################################################################################################

################################################################################################
## Go bits
################################################################################################
PATH=$PATH:/usr/local/go/bin
export PATH="~/go/bin:$PATH"
################################################################################################
## End of Go bits
################################################################################################

################################################################################################
## Homeserver stuff 
################################################################################################
export SOPS_AGE_KEY_FILE=$HOME/.sops/key.txt
export KUBECONFIG=~/.kube/config
alias promload2="curl -L -X POST prometheus.dr.knxcloud.io/-/reload"
alias k=kubectl
################################################################################################
## End of Homeserver stuff
################################################################################################

################################################################################################
## GCP
################################################################################################
[ -f ~/bin/google-cloud-sdk/path.zsh.inc ] && . ~/bin/google-cloud-sdk/path.zsh.inc
[ -f ~/bin/google-cloud-sdk/completion.zsh.inc ] && . ~/bin/google-cloud-sdk/completion.zsh.inc
################################################################################################
## End of GCP
################################################################################################

################################################################################################
## History
################################################################################################
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
################################################################################################
## End of History
################################################################################################

################################################################################################
## ZSH key bindings
################################################################################################
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line
################################################################################################
## End of ZSH key bindings
################################################################################################

################################################################################################
## Work specific shell setup
################################################################################################
[ -r ~/.work_shell ] && . ~/.work_shell
# Stub for any work specific sc I use at this point in time
# yet another source control
prompt_yasc() {}
################################################################################################
## End of Work specific shell setup
################################################################################################

################################################################################################
## Bring in host level overrides file if its there
################################################################################################
[ -r ~/.host_shell ] && . ~/.host_shell
################################################################################################
## End of host level overrides file
################################################################################################

################################################################################################
## Rust setup
################################################################################################
[ -r ~/.cargo/env ] && . ~/.cargo/env
################################################################################################
## End of Rust setup
################################################################################################

################################################################################################
## BACKUP prompt when powerlevel10k is not available
################################################################################################
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

################################################################################################
## END OF BACKUP PROMPT
################################################################################################

################################################################################################
## POWERLEVEL10K
################################################################################################
# Source powerlevel10k if it is available
[ -f ~/powerlevel10k/powerlevel10k.zsh-theme ] && . ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
################################################################################################
## END OF POWERLEVEL10K
################################################################################################

################################################################################################
## fzf
################################################################################################
if type fzf &>/dev/null
then
  source <(fzf --zsh)
fi
################################################################################################
## End of fzf
################################################################################################

################################################################################################
## 1password
################################################################################################
if type op &>/dev/null
then
  eval "$(op completion zsh)"
  compdef _op op
fi
################################################################################################
## End of 1password
################################################################################################

################################################################################################
## Homebrew completions
################################################################################################
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit
fi
################################################################################################
## End of Homebrew completions
################################################################################################

################################################################################################
## Colourful ls
################################################################################################
# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
  colorflag="--color"
else # OS X `ls`
  colorflag="-G"
fi

# List all files colorized in long format
alias ll='ls -lh'

# List all files colorized in long format, including dot files
alias la="ls -lha"

# List only directories
alias lsd='ls -l | grep "^d"'

# Always use color output for `ls`
alias ls="command ls ${colorflag}"
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'
################################################################################################
## End of Colourful ls
################################################################################################