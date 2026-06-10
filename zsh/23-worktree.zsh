# __wt_path_for_branch <branch>
# 指定ブランチに対応する worktree の絶対パスを返す。存在しなければ空文字。
__wt_path_for_branch() {
  git worktree list --porcelain | awk -v b="refs/heads/$1" '
    /^worktree / { w = $2 }
    $0 == "branch " b { print w; exit }
  '
}

# wt — git worktree all-in-one manager
#
#   wt                     fzf で branch を選択 → worktree に移動 (なければ作成)
#   wt <branch>            branch の worktree へ移動 (なければ作成)
#   wt -b <branch> [base]  新規ブランチ + worktree を作成して移動
#   wt rm [branch]         worktree を削除 (省略時は fzf で選択)
#   wt ls                  worktree 一覧を表示
wt() {
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "wt: not inside a git repository" >&2
    return 1
  fi

  local git_root repo_name git_dir
  # git_root の解決:
  # - 通常リポ / linked worktree: worktree list の先頭 = main worktree のパス
  #   (show-toplevel は linked worktree 内では linked root を返すため不可)
  # - サブモジュール内: git dir が .git/modules/ 以下にあり worktree list が
  #   git dir 自体を返してしまうため show-toplevel を使う
  git_dir=$(git rev-parse --absolute-git-dir 2>/dev/null)
  if [[ "$git_dir" == *"/.git/modules/"* ]]; then
    git_root=$(git rev-parse --show-toplevel)
  else
    git_root=$(git worktree list --porcelain | awk 'NR==1{print $2}')
  fi
  repo_name="${git_root:t}"

  case "$1" in

    # ── wt ls ────────────────────────────────────────────────────────────
    ls|list)
      git worktree list
      ;;

    # ── wt rm [branch] ───────────────────────────────────────────────────
    rm|remove)
      local wt_path
      if [[ -z "$2" ]]; then
        local selected
        selected=$(git worktree list --porcelain | awk -v root="$git_root" '
          /^worktree / { path = $2; next }
          /^branch refs\/heads\// {
            if (path == root) next
            b = $2; sub(/^refs\/heads\//, "", b)
            print b "\t" path
          }
        ' | fzf +m --with-nth=1 --delimiter=$'\t' --prompt="wt rm> ")
        [[ -z "$selected" ]] && return 0
        wt_path="${selected#*$'\t'}"
      else
        wt_path=$(__wt_path_for_branch "$2")
        if [[ -z "$wt_path" ]]; then
          echo "wt rm: '$2' に対応する worktree が見つからない" >&2
          return 1
        fi
      fi
      if ! git worktree remove "$wt_path" 2>/dev/null; then
        echo "wt rm: ダーティな変更があります。強制削除しますか? [y/N] " >&2
        local reply
        read -r reply
        [[ "$reply" =~ ^[Yy]$ ]] || return 1
        git worktree remove --force "$wt_path"
      fi
      ;;

    # ── wt -b <new-branch> [base] ─────────────────────────────────────
    -b|--branch)
      local new_branch="$2" base="${3:-HEAD}"
      if [[ -z "$new_branch" ]]; then
        echo "usage: wt -b <new-branch> [base]" >&2
        return 1
      fi
      local wt_dest="${git_root:h}/.worktrees/${repo_name}/${new_branch}"
      git worktree add -b "$new_branch" "$wt_dest" "$base" || return $?
      cd "$wt_dest"
      ;;

    # ── 引数なし: fzf で branch を選択 ──────────────────────────────
    "")
      local selected branch
      selected=$(
        {
          # [wt] グループ: 既存 worktree を持つブランチ
          git worktree list --porcelain | awk '
            /^worktree / { path = $2; next }
            /^branch refs\/heads\// {
              b = $2; sub(/^refs\/heads\//, "", b)
              print "[wt] " b "\t" b
            }
          '
          # その他のローカルブランチ (worktree なし)
          git for-each-ref --format='%(refname:short)' refs/heads/ | \
          awk -v wt="$(git worktree list --porcelain | awk \
            '/^branch refs\/heads\//{b=$2; sub(/^refs\/heads\//,"",b); printf "%s\n",b}')" '
            BEGIN { n=split(wt,a,"\n"); for(i=1;i<=n;i++) if(a[i]!="") seen[a[i]]=1 }
            !($0 in seen) { print "     " $0 "\t" $0 }
          '
        } | fzf +m --with-nth=1 --delimiter=$'\t' --prompt="worktree> "
      )
      [[ -z "$selected" ]] && return 0
      branch="${selected##*$'\t'}"
      wt "$branch"
      ;;

    # ── wt <branch>: 既存 worktree へ移動、なければ作成 ──────────────
    *)
      local branch="$1" wt_path
      wt_path=$(__wt_path_for_branch "$branch")
      if [[ -n "$wt_path" ]]; then
        cd "$wt_path"
        return 0
      fi
      if git show-ref --verify --quiet "refs/heads/$branch"; then
        local wt_dest="${git_root:h}/.worktrees/${repo_name}/${branch}"
        git worktree add "$wt_dest" "$branch" || return $?
        cd "$wt_dest"
        return 0
      fi
      echo "wt: branch '$branch' が見つからない" >&2
      local candidates
      candidates=$(git for-each-ref --format='%(refname:short)' refs/heads/ refs/remotes/ \
        | grep -i -- "$branch" | head -10)
      if [[ -n "$candidates" ]]; then
        echo "もしかして:" >&2
        echo "$candidates" >&2
      fi
      return 1
      ;;
  esac
}

# _wt: zsh 補完
_wt() {
  local state
  _arguments \
    '1: :->cmd' \
    '*: :->args' && return

  local -a wt_branches all_branches other_branches
  wt_branches=(${(f)"$(git worktree list --porcelain 2>/dev/null | awk '
    /^branch refs\/heads\// { b=$2; sub(/^refs\/heads\//,"",b); print b }
  ')"})
  all_branches=(${(f)"$(git for-each-ref --format='%(refname:short)' refs/heads/ 2>/dev/null)"})
  other_branches=(${all_branches:|wt_branches})

  case $state in
    cmd)
      local -a subcmds
      subcmds=('ls:worktree一覧' 'rm:worktree削除' '-b:新規ブランチ+worktree作成')
      _describe -t subcommand 'subcommand' subcmds
      _describe -t wt-worktree 'worktree' wt_branches
      _describe -t wt-branch 'branch' other_branches
      ;;
    args)
      case $words[2] in
        rm|remove)
          _describe -t wt-worktree 'worktree' wt_branches ;;
        -b|--branch)
          ;; # 新規ブランチ名は自由入力
        *)
          _describe -t wt-worktree 'worktree' wt_branches
          _describe -t wt-branch 'branch' other_branches ;;
      esac
      ;;
  esac
}
if (( $+functions[compdef] )); then
  compdef _wt wt
fi

# gco <branch>: git checkout のラッパー。
# branch がすでに worktree で使われていた場合、エラーにせずその worktree へ cd する。
# oh-my-zsh git plugin が gco を alias として定義するため先に解除する。
unalias gco 2>/dev/null
gco() {
  local err exit_code
  err=$(git checkout "$@" 2>&1)
  exit_code=$?

  if [[ $exit_code -eq 0 ]]; then
    [[ -n "$err" ]] && printf '%s\n' "$err" >&2
    return 0
  fi

  local wt_path
  wt_path=$(printf '%s\n' "$err" | sed -nE "s/.*is already used by worktree at '([^']+)'.*/\1/p" | head -n1)
  if [[ -n "$wt_path" ]]; then
    printf '%s\n' "$err" >&2
    cd "$wt_path"
    return 0
  fi

  printf '%s\n' "$err" >&2
  return $exit_code
}
compdef _git gco=checkout
