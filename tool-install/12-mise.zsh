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

if ! grep -q 'mise activate' "$HOME/.zshrc" 2>/dev/null; then
  cat >> "$HOME/.zshrc" <<'EOF'

# mise
export PATH="$HOME/.local/bin:$PATH"
eval "$(mise activate zsh)"
EOF
  echo "Added mise activation to ~/.zshrc"
fi

echo "Installed: $(mise --version)"
