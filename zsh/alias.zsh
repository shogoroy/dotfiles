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

# kube
alias kube="kubectl"

# fzf
alias fzf="fzf-tmux"

if builtin command -v ghq > /dev/null 2>&1 ; then
  flook() {
    local dir
    dir=$(ghq list | fzf +m)
    if [[ "$dir" != "" ]]; then
      cd "`ghq root`/$dir"
    fi
  }
fi

if builtin command -v nvim > /dev/null 2>&1 ; then
  fnvim() {
    local dir
    dir=$(fzf +m)
    if [[ "$dir" != "" ]]; then
      nvim $dir
    fi
  }
fi

