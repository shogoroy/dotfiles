# git aliases
alias gitfp='git fetch --prune'
alias gits='git status'
alias gfp='gitfp'
alias gs='gits'

# gitclean: remote の default branch に merge 済みの local branch と worktree を削除する。
# -n / --dry-run で削除対象を表示するだけ。
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
    git fetch --prune || return
  else
    git checkout "$default_branch" && git fetch --prune && git pull || return
  fi

  local branches branch wt_path
  # NOTE: `git branch --merged --format=...` は `--merged` が `--format=...` を
  #       比較対象コミットとして食うため、比較対象を明示する。
  branches=$(git branch --merged "origin/${default_branch}" --format='%(refname:short)' | grep -v "^${default_branch}\$")

  for branch in ${(f)branches}; do
    [[ -z "$branch" ]] && continue

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

# fzf + git
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

  local result file line_number
  result=$(git grep -n $1 | fzf --ansi | cut -d: -f1,2)
  file=$(echo $result | cut -d: -f1)
  line_number=$(echo $result | cut -d: -f2)

  if [[ "$file" != "" ]]; then
    print -z "nvim +$line_number $file"
  fi
}
