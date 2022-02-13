for file in ~/.{path,aliases}; do
  [ -r "$file" ] && source "$file"
done
unset file

# Bring in OS specific stuff
case $OSTYPE in
    darwin*)
      [ -r ~/.osx_shell ] && . ~/.osx_shell
    ;;
    linux*)
      [ -r ~/.linux_shell ] && . ~/.linux_shell
    ;;
esac

# Bring in work specific file if its there
[ -r ~/.work_shell ] && . ~/.work_shell

# Bring in host level overrides file if its there
[ -r ~/.host_shell ] && . ~/.host_shell