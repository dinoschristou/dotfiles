export EDITOR="atom -w"
alias vim='mvim -v'
alias la='ls -a'

for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
  [ -r "$file" ] && source "$file"
done
unset file

code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}
#ßsource dnvm.sh
