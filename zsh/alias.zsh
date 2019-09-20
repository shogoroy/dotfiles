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

# go
alias cdgo='cd $GOPATH'

# git
alias gitclean='git checkout master && git fetch --prune && git pull && git branch --merged | grep -v "*"| xargs git branch -d'
alias gitdiff='git diff'
alias gitfp='git fetch --prune'
alias gits='git status'

alias gclean='gitclean'
alias gd='gitdiff'
alias gdiff='gitdiff'
alias gfp='gitfp'
alias gs='gits'

# github
eval "$(hub alias -s)"

# kube
alias kube="kubectl"
