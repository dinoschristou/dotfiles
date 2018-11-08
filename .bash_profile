export EDITOR="mvim -v"
alias vim='mvim -v'
alias la='ls -a'

for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
  [ -r "$file" ] && source "$file"
done
unset file


export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"

#source /usr/local/lib/dnx/bin/dnvm.sh
eval $(/usr/libexec/path_helper -s)

# added by Anaconda3 5.2.0 installer
export PATH="/anaconda3/bin:$PATH"

# added by Anaconda3 5.2.0 installer
export PATH="/Users/dinos/anaconda3/bin:$PATH"
. /Users/dinos/anaconda3/etc/profile.d/conda.sh
