#!/usr/bin/env bash
# dot-update.sh - Apply dotfiles configuration with nix run .#switch
# Usage: ./dot-update.sh

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/ghq/github.com/nazozokc/dotfiles}"

cd "$DOTFILES_DIR"

echo "========================================="
echo "  Dotfiles Update (nix run .#switch)"
echo "========================================="
echo ""

# Check if we're in a git repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "Error: Not in a git repository ($DOTFILES_DIR)"
  exit 1
fi

# Show current status
echo "Current branch: $(git branch --show-current)"
echo ""

# Run switch
echo "Applying configuration..."
nix run .#switch

echo ""
echo "========================================="
echo "  Update complete!"
echo "========================================="
