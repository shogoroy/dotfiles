# ls
if [ "$(uname)" = 'Darwin' ]; then
  alias ls='ls -aGF'
  # ls の色
  export LSCOLORS=gxfxcxdxbxegedabagacad

else
  alias ls='ls -a --color=auto'
  # ls の色
  export LS_COLORS="${LS_COLORS}:di=01;36"
fi

# cdgo
alias cdgo='cd $GOPATH'

# git
alias gs='git status'
alias gclean='git checkout master && git fetch --prune && git pull && git branch --merged | xargs git branch -d'
