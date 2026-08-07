# git aliases
alias gitfp='git fetch --prune'
alias gits='git status'
alias gfp='gitfp'
alias gs='gits'
gbc() { git branch --contains "${1:-HEAD}" }
compdef '_alternative "refs:branch:__git_branch_names"' gbc

# __git_head_is_pushed_or_merged <repo_path> [default_branch_hint]
# <repo_path> の HEAD が、何らかの remote-tracking ref に含まれる (push 済み) か、
# default branch (origin/<default_branch_hint> または origin/HEAD の指す branch) に
# マージ済みであれば 0 を返す。
__git_head_is_pushed_or_merged() {
  local repo_path="$1" branch_hint="$2"
  local head_sha
  head_sha=$(git -C "$repo_path" rev-parse HEAD 2>/dev/null) || return 1

  # push 済み判定: 任意の remote-tracking ref に含まれていれば OK
  [[ -n "$(git -C "$repo_path" branch -r --contains "$head_sha" 2>/dev/null)" ]] && return 0

  # マージ済み判定: .gitmodules の branch= (呼び出し元から渡された hint) を優先し、
  # 無ければ origin/HEAD が指す branch を使う
  local default_branch="$branch_hint"
  [[ -n "$default_branch" ]] || default_branch=$(
    git -C "$repo_path" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | awk -F'/' '{print $NF}'
  )
  [[ -n "$default_branch" ]] || return 1

  git -C "$repo_path" merge-base --is-ancestor "$head_sha" "origin/${default_branch}" 2>/dev/null
}

# __git_worktree_safe_to_force <wt_path>
# <wt_path> の main module と (フラットな) submodule すべてについて、
# 実際の未コミット変更が無く、かつ HEAD が push 済み/マージ済みであれば 0 を返す。
# git worktree remove は submodule が存在するだけで --force を要求するため、
# 「本当に失うものがあるか」をこの関数で明示的に判定する。
__git_worktree_safe_to_force() {
  local wt_path="$1"

  # main module: submodule 由来の差分は無視して実ダーティのみ見る
  [[ -z "$(git -C "$wt_path" status --porcelain --ignore-submodules=all 2>/dev/null)" ]] || return 1
  __git_head_is_pushed_or_merged "$wt_path" || return 1

  local gitmodules="$wt_path/.gitmodules"
  [[ -f "$gitmodules" ]] || return 0

  local sub_path sub_name sub_branch sub_dir
  while IFS= read -r sub_path; do
    [[ -z "$sub_path" ]] && continue
    sub_dir="$wt_path/$sub_path"
    [[ -e "$sub_dir/.git" ]] || continue  # 未初期化 submodule は削除対象にならないのでスキップ

    [[ -z "$(git -C "$sub_dir" status --porcelain 2>/dev/null)" ]] || return 1

    sub_name=$(git config --file "$gitmodules" --get-regexp 'submodule\..*\.path' \
      | awk -v p="$sub_path" '$2==p{print $1}' | sed -E 's/^submodule\.(.*)\.path$/\1/')
    sub_branch=$(git config --file "$gitmodules" --get "submodule.${sub_name}.branch" 2>/dev/null)

    __git_head_is_pushed_or_merged "$sub_dir" "$sub_branch" || return 1
  done < <(git config --file "$gitmodules" --get-regexp 'submodule\..*\.path' 2>/dev/null | awk '{print $2}')

  return 0
}

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
      if [[ -n "$wt_path" ]]; then
        if __git_worktree_safe_to_force "$wt_path"; then
          echo "[dry-run] remove worktree: $wt_path (push/マージ済みのため確認なしで強制削除)"
        else
          echo "[dry-run] remove worktree: $wt_path"
        fi
      fi
      echo "[dry-run] delete branch:   $branch"
      continue
    fi

    if [[ -n "$wt_path" ]]; then
      if ! git worktree remove "$wt_path" 2>/dev/null; then
        if __git_worktree_safe_to_force "$wt_path"; then
          git worktree remove --force "$wt_path"
        else
          echo "gitclean: '$wt_path' はダーティです。強制削除しますか? [y/N] " >&2
          local reply
          read -r reply
          [[ "$reply" =~ ^[Yy]$ ]] || { echo "gitclean: スキップ: $branch" >&2; continue; }
          git worktree remove --force "$wt_path"
        fi
      fi
    fi

    git branch -d "$branch"
  done
}

# fzf + git
fgco() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD)
  branch=$(echo "$branches" | fzf -d $(( 2 + $(wc -l <<< "$branches") )) +m | sed "s/.* //" | sed "s#remotes/[^/]*/##")
  print -z "gco $branch"
}

fgbr() {
  fgco
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
