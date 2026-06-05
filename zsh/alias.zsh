# ls
if [ "$(uname)" = 'Darwin' ]; then
  alias ls='ls -aGF'
  export LSCOLORS=gxfxcxdxbxegedabagacad
else
  alias ls='ls -a --color=auto'
  export LS_COLORS="${LS_COLORS}:di=01;36"
fi

# sed
if builtin command -v gsed > /dev/null 2>&1 ; then
  sed() { gsed -E "$@"; }
fi

# go
alias cdgo='cd $GOPATH'

# kube
alias kube="kubectl"

# grep
if builtin command -v grep > /dev/null 2>&1 ; then
  alias grep='grep --color=auto'
  alias egrep='egrep --color=auto'
  alias fgrep='fgrep --color=auto'
fi
