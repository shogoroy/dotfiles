# mise (PATH を最終形に整えるため、zsh/ の最後に読み込む)
export PATH="$HOME/.local/bin:$PATH"

if command -v mise &>/dev/null; then
  # 入れ子の zsh で、親シェルの古い PATH を「元の PATH」として復元されないようにする
  unset __MISE_ORIG_PATH __MISE_DIFF __MISE_SESSION
  eval "$(mise activate zsh)"
fi
