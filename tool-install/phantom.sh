# phantom (git worktree マネージャ) を未インストールなら入れる
# 配布は Homebrew / npm のみ (GitHub Release の単体バイナリは無い) ため
# zplug の from:gh-r ではなくここで入れる
if ! type phantom > /dev/null 2>&1; then
  if type brew > /dev/null 2>&1; then
    brew install aku11i/tap/phantom
  elif type npm > /dev/null 2>&1; then
    npm install -g @aku11i/phantom
  fi
fi
