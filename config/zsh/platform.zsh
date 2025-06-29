# Platform-specific configuration

case $OSTYPE in
    darwin*)
        # Homebrew
        eval "$(/opt/homebrew/bin/brew shellenv)"
        export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"
        export PATH="/opt/homebrew/opt/openssl@1.1/bin:$PATH"
        [[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"

        # ZSH plugins (Homebrew)
        [ -r /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && . '/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh'
        [ -r /opt/homebrew/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ] && . '/opt/homebrew/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh'
        
        # iTerm2 integration
        [ -f ~/.iterm2_shell_integration.zsh ] && . ~/.iterm2_shell_integration.zsh
    ;;
    linux*)
        # Linux-specific shell configuration
        [ -r ~/.linux_shell ] && . ~/.linux_shell
        
        # ZSH plugins (system packages)
        [ -r ~/.zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ] && . ~/.zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
        [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        [ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ] && . ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
    ;;
esac