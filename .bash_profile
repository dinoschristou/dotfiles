export EDITOR="atom -w"
alias vim='mvim -v'
alias la='ls -a'

for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
  [ -r "$file" ] && source "$file"
done
unset file

source /usr/local/lib/dnx/bin/dnvm.sh
