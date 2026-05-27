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
  sed() { gsed -E "$@"; }
fi


# go
alias cdgo='cd $GOPATH'

# git
# remote の default branch に merge 済みの local branch と、それに紐づく worktree を削除する。
# -n / --dry-run を渡すと、作業ツリーを変更せず「何が削除されるか」だけを表示する。
gitclean() {
  local dry_run=0
  [[ "$1" == "-n" || "$1" == "--dry-run" ]] && dry_run=1

  local default_branch
  default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | awk -F'[/]' '{print $NF}')
  if [[ -z "$default_branch" ]]; then
    echo "gitclean: origin/HEAD を解決できません。'git remote set-head origin -a' を試してください" >&2
    return 1
  fi

  if (( dry_run )); then
    # dry-run では checkout / pull を行わず、最新の merge 状態を反映するため fetch のみ実施する
    git fetch --prune || return
  else
    git checkout "$default_branch" && git fetch --prune && git pull || return
  fi

  local branches branch wt_path
  # NOTE: `git branch --merged --format=...` と書くと `--merged` が直後の `--format=...` を
  #       比較対象コミットとして食ってしまい `fatal: malformed object name` になる。
  #       比較対象 (origin/<default>) を明示することで回避し、checkout の有無にも依存しないようにする。
  branches=$(git branch --merged "origin/${default_branch}" --format='%(refname:short)' | grep -v "^${default_branch}\$")

  for branch in ${(f)branches}; do
    [[ -z "$branch" ]] && continue

    # マージ済みブランチに worktree が紐づいていれば先に worktree ごと削除する
    wt_path=$(git worktree list --porcelain | awk -v b="refs/heads/$branch" '
      /^worktree / { w = $2 }
      $0 == "branch " b { print w; exit }
    ')

    if (( dry_run )); then
      [[ -n "$wt_path" ]] && echo "[dry-run] remove worktree: $wt_path"
      echo "[dry-run] delete branch:   $branch"
      continue
    fi

    if [[ -n "$wt_path" ]]; then
      git worktree remove "$wt_path" 2>/dev/null || git worktree remove --force "$wt_path"
    fi

    git branch -d "$branch"
  done
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

fnvimgd() {
  local files file
  files=$(git diff --name-only $1 | uniq)
  file=$(echo "$files" | fzf -d $(( 2 + $(wc -l <<< "$files") )) +m | sed "s/.* //" | sed "s#remotes/[^/]*/##")
  if [[ "$file" != "" ]]; then
    print -z "nvim $file"
  fi
}

alias nvimgd="git diff --name-only | uniq | xargs nvim"

gdl() {
  git diff --name-only $1 | uniq
}
alias gdln="gdl | xargs nvim"

ggr() {
  git grep $1
}

fgn() {
  if [[ $1 == "" ]]; then
    ggr
    return
  fi

  local file

  result=$(git grep -n $1 | fzf --ansi | cut -d: -f1,2)
  file=$(echo $result | cut -d: -f1)
  line_number=$(echo $result | cut -d: -f2)

  if [[ "$file" != "" ]]; then
      print -z "nvim +$line_number $file"
  fi
}

ffind() {
  dir=./
  if [[ -n "$1" ]]; then
    dir=$1
  fi

  file=$(find $dir | fzf --ansi)
  if [[ "$file" != "" ]]; then
      print -z "$file"
  fi
}

fwt() {
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "fwt: not inside a git repository" >&2
    return 1
  fi
  local selected dir
  selected=$(git worktree list --porcelain | awk '
    /^worktree / { path = $2; next }
    /^branch refs\/heads\// {
      branch = $2
      sub(/^refs\/heads\//, "", branch)
      print branch "\t" path
    }
  ' | fzf +m --with-nth=1 --delimiter=$'\t')
  if [[ -n "$selected" ]]; then
    dir=${selected#*$'\t'}
    cd "$dir"
  fi
}

# git checkout 系のコマンドが「branch is already used by worktree at ...」で
# 失敗した直後に gcowt を実行すると、そのエラーに含まれる worktree path へ cd する。
# 引数でブランチ名を渡した場合は、そのブランチに対応する worktree path を
# `git worktree list --porcelain` から引いて cd する。
gcowt() {
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "gcowt: not inside a git repository" >&2
    return 1
  fi

  local wt_path

  if [[ -n "$1" ]]; then
    # 引数指定: ブランチ名 → worktree path
    local branch="$1"
    wt_path=$(git worktree list --porcelain | awk -v b="refs/heads/$branch" '
      /^worktree / { w = $2 }
      $0 == "branch " b { print w; exit }
    ')
    if [[ -z "$wt_path" ]]; then
      echo "gcowt: branch '$branch' に対応する worktree が見つからない" >&2
      return 1
    fi
  else
    # 引数なし: 直前のコマンドを再実行して stderr から worktree path を抽出
    local last_cmd
    last_cmd=$(fc -ln -1 2>/dev/null | sed 's/^[[:space:]]*//')
    if [[ -z "$last_cmd" ]]; then
      echo "gcowt: 直前のコマンドが取得できなかった" >&2
      return 1
    fi
    # 安全のため git checkout / gco / git switch のみ再実行を許可する
    if [[ ! "$last_cmd" =~ ^(gco|git[[:space:]]+(checkout|switch))[[:space:]] ]]; then
      echo "gcowt: 直前のコマンドが git checkout 系ではない: $last_cmd" >&2
      return 1
    fi
    local err
    err=$(eval "$last_cmd" 2>&1 >/dev/null)
    # "fatal: '<branch>' is already used by worktree at '<path>'" から path を取り出す
    wt_path=$(echo "$err" | sed -nE "s/.*is already used by worktree at '([^']+)'.*/\1/p" | head -n1)
    if [[ -z "$wt_path" ]]; then
      echo "gcowt: 直前のエラーから worktree path を抽出できなかった" >&2
      [[ -n "$err" ]] && echo "$err" >&2
      return 1
    fi
  fi

  cd "$wt_path"
}
