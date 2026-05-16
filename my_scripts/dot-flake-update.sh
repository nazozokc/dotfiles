#!/usr/bin/env bash
# dot-flake-update.sh - Update flake inputs and show diff
# Usage: ./dot-flake-update.sh

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/ghq/github.com/nazozokc/dotfiles}"

cd "$DOTFILES_DIR"

echo "========================================="
echo "  Flake Update (nix run .#update)"
echo "========================================="
echo ""

# Check if we're in a git repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "Error: Not in a git repository ($DOTFILES_DIR)"
  exit 1
fi

# Show current lock status
echo "Current flake.lock changes:"
echo "-----------------------------------------"
git diff --stat flake.lock 2>/dev/null || echo "(no changes yet)"
echo ""

# Run update
echo "Updating flake inputs..."
nix run .#update

echo ""
echo "========================================="
echo "  Flake update complete!"
echo "========================================="
echo ""

# Show diff
echo "Changes in flake.lock:"
echo "-----------------------------------------"
git diff flake.lock 2>/dev/null || echo "(unable to show diff)"
