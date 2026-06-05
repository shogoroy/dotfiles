[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

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
    local dir file
    dir=${1:="."}
    file=$(find $dir | fzf +m)
    if [[ "$file" != "" ]]; then
      print -z "nvim $file"
    fi
  }
fi

ffind() {
  local dir file
  dir=${1:-./}
  file=$(find $dir | fzf --ansi)
  if [[ "$file" != "" ]]; then
    print -z "$file"
  fi
}
