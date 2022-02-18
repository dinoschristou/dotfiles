# Use .profile to be compatible with non Bash shells
if [ -r ~/.profile ]; then . ~/.profile; fi

# If running in interactive mode then source .bashrc
case "$-" in *i*) if [ -r ~/.bashrc ]; then . ~/.bashrc; fi;; esac