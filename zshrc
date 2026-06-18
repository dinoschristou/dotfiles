export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# PATH
export PATH="/usr/local/bin:$HOME/bin:$HOME/.local/bin:$PATH"
export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"
export PATH="$HOME/.antigravity/antigravity/bin:$HOME/.antigravity-ide/antigravity-ide/bin:$PATH"

# Environment
export SOPS_AGE_KEY_FILE=$HOME/.sops/key.txt
export KUBECONFIG=$HOME/.kube/config
[[ -r $HOME/.cargo/env ]] && . $HOME/.cargo/env

# History
setopt EXTENDED_HISTORY INC_APPEND_HISTORY SHARE_HISTORY
setopt HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS HIST_VERIFY APPEND_HISTORY HIST_NO_STORE HIST_REDUCE_BLANKS
setopt hist_expire_dups_first
unsetopt hist_beep
HISTFILE=~/.zsh_history
HISTSIZE=500000
SAVEHIST=500000
HISTORY_IGNORE="(ls|cd|pwd|exit|*ANSIBLE_VAULT_PASS*|ansible-vault)"
zshaddhistory() { emulate -L zsh; [[ $1 != ${~HISTORY_IGNORE} ]] }

# Keybindings
bindkey '^[[3~'   delete-char        # Delete
bindkey '^[[1;5C' forward-word       # Ctrl+Right
bindkey '^[[1;5D' backward-word      # Ctrl+Left
bindkey "^[[H"    beginning-of-line  # Home
bindkey "^[[F"    end-of-line        # End

# Completion
type brew &>/dev/null && FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
autoload -Uz compinit && compinit
[[ -t 1 ]] && command -v op &>/dev/null && { eval "$(op completion zsh)"; compdef _op op }
type fzf &>/dev/null && source <(fzf --zsh)
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# Platform
case $OSTYPE in
    darwin*)
        eval "$(/opt/homebrew/bin/brew shellenv)"
        export PATH="/opt/homebrew/opt/sqlite/bin:/opt/homebrew/opt/openssl@1.1/bin:$PATH"
        export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
        [[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"
        [[ -r /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && . /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        [[ -r /opt/homebrew/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]] && . /opt/homebrew/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
    ;;
    linux*)
        [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && . /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        [[ -r ~/.zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]] && . ~/.zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
        [[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && . ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
    ;;
esac

# Prompt
if type starship &>/dev/null; then
    eval "$(starship init zsh)"
else
    PROMPT='%(?.%F{green}√.%F{red}?%?)%f %B%F{240}%1~%f%b %# '
    autoload -Uz vcs_info
    precmd_functions+=( vcs_info )
    setopt prompt_subst
    RPROMPT=\$vcs_info_msg_0_
    zstyle ':vcs_info:git:*' formats '%F{240}(%b)%r%f'
    zstyle ':vcs_info:*' enable git
fi

# Aliases
ls --color > /dev/null 2>&1 && colorflag="--color" || colorflag="-G"
alias ls="command ls ${colorflag}"
alias ll='ls -lh'
alias la='ls -lha'
alias lsd='ls -l | grep "^d"'
alias k=kubectl
alias sysinfo='fastfetch 2>/dev/null || neofetch'
alias ff='fastfetch'
case $OSTYPE in
    darwin*) alias tailscale=/Applications/Tailscale.app/Contents/MacOS/Tailscale ;;
esac
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'

# External tools
[[ -r $HOME/.atuin/bin/env ]] && . $HOME/.atuin/bin/env
command -v atuin &>/dev/null && eval "$(atuin init zsh)"
[[ -f $HOME/bin/google-cloud-sdk/path.zsh.inc ]] && . $HOME/bin/google-cloud-sdk/path.zsh.inc
[[ -f $HOME/bin/google-cloud-sdk/completion.zsh.inc ]] && . $HOME/bin/google-cloud-sdk/completion.zsh.inc
[[ -f $HOME/google-cloud-sdk/path.zsh.inc ]] && . $HOME/google-cloud-sdk/path.zsh.inc
[[ -f $HOME/google-cloud-sdk/completion.zsh.inc ]] && . $HOME/google-cloud-sdk/completion.zsh.inc

# User overrides
[[ -r ~/.work_shell ]] && source ~/.work_shell
[[ -r ~/.host_shell ]] && source ~/.host_shell
[[ -r ~/.env ]] && source ~/.env
