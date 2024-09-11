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

# sed
if builtin command -v gsed > /dev/null 2>&1 ; then
  alias sed='gsed'
fi


# go
alias cdgo='cd $GOPATH'

# git
gitclean() {
  local default_branch=$(git symbolic-ref refs/remotes/origin/HEAD | awk -F'[/]' '{print $NF}')
  git checkout $default_branch && git fetch --prune && git pull && git branch --merged | grep -v "*"| xargs git branch -d
}
alias gitfp='git fetch --prune'
alias gits='git status'

alias gfp='gitfp'
alias gs='gits'

# kube
alias kube="kubectl"

# grep
if builtin command -v grep > /dev/null 2>&1 ; then
  alias grep='grep --color=auto'
  alias egrep='egrep --color=auto'
  alias fgrep='fgrep --color=auto'
fi

#
# fzf
#
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
    dir=${1:="."}
    file=$(find $dir | fzf +m)
    if [[ "$file" != "" ]]; then
      print -z "nvim $file"
    fi
  }
fi

fgbr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD)
  branch=$(echo "$branches" | fzf -d $(( 2 + $(wc -l <<< "$branches") )) +m | sed "s/.* //" | sed "s#remotes/[^/]*/##")
  print -z "git checkout $branch"
}

fgm() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD)
  branch=$(echo "$branches" | fzf -d $(( 2 + $(wc -l <<< "$branches") )) +m | sed "s/.* //" | sed "s#remotes/[^/]*/##")
  print -z "git merge $branch"
}

fgd() {
  local files file
  files=$(git diff --name-only $1)
  file=$(echo "$files" | fzf -d $(( 2 + $(wc -l <<< "$files") )) +m | sed "s/.* //" | sed "s#remotes/[^/]*/##")
  print -z "nvim $file"
}
