#!/usr/bin/env zsh
# Install mise (version manager) via the official installer.
# https://github.com/jdx/mise-docs/blob/main/getting-started.md

set -euo pipefail

if command -v mise &>/dev/null; then
  echo "mise $(mise --version) is already installed at $(which mise)"
  exit 0
fi

echo "Installing mise via the official installer..."
curl https://mise.run | sh

export PATH="$HOME/.local/bin:$PATH"

echo "Installed: $(mise --version)"
echo "mise is activated by zsh/90-mise.zsh from the next shell"
