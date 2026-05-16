#!/usr/bin/env bash
# dot-build.sh - Build dotfiles configuration without applying
# Usage: ./dot-build.sh

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/ghq/github.com/nazozokc/dotfiles}"

cd "$DOTFILES_DIR"

echo "========================================="
echo "  Dotfiles Build (nix run .#build)"
echo "========================================="
echo ""

# Check if we're in a git repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "Error: Not in a git repository ($DOTFILES_DIR)"
  exit 1
fi

echo "Building configuration..."
nix run .#build

echo ""
echo "========================================="
echo "  Build complete!"
echo "========================================="
