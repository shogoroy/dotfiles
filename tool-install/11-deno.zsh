#!/usr/bin/env zsh
# Install Deno globally. Prefers Homebrew; falls back to the official installer.

set -euo pipefail

if command -v deno &>/dev/null; then
  echo "deno $(deno --version | head -1) is already installed at $(which deno)"
  exit 0
fi

if command -v brew &>/dev/null; then
  echo "Installing deno via Homebrew..."
  brew install deno
else
  echo "Homebrew not found. Using the official installer..."
  curl -fsSL https://deno.land/install.sh | sh

  export DENO_INSTALL="$HOME/.deno"
  export PATH="$DENO_INSTALL/bin:$PATH"

  if ! grep -q 'DENO_INSTALL' "$HOME/.zshrc" 2>/dev/null; then
    cat >> "$HOME/.zshrc" <<'EOF'

# Deno
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
EOF
    echo "Added DENO_INSTALL to ~/.zshrc"
  fi
fi

echo "Installed: $(deno --version | head -1)"
