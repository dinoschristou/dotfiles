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

. /Users/dinos/anaconda3/etc/profile.d/conda.sh
# added by Anaconda3 5.3.0 installer
# >>> conda init >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$(CONDA_REPORT_ERRORS=false '/Users/dinos/anaconda3/bin/conda' shell.bash hook 2> /dev/null)"
if [ $? -eq 0 ]; then
    \eval "$__conda_setup"
else
    if [ -f "/Users/dinos/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/dinos/anaconda3/etc/profile.d/conda.sh"
        CONDA_CHANGEPS1=false conda activate base
    else
        \export PATH="/Users/dinos/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda init <<<
