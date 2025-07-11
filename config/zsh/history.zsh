# ZSH history configuration

# History options
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

# History file and size
HISTFILE=~/.zsh_history
HISTSIZE=500000
SAVEHIST=500000
HISTORY_IGNORE="(ls|cd|pwd|exit|cd|*ANSIBLE_VAULT_PASS*|ansible-vault)"
HIST_STAMPS="yyyy-mm-dd"

# Custom history filter function
zshaddhistory() {
  emulate -L zsh
  [[ $1 != ${~HISTORY_IGNORE} ]]
}