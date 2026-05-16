#!/usr/bin/env bash
# nvim-update.sh - Update Neovim plugins and LSP servers
# Usage: ./nvim-update.sh

set -euo pipefail

echo "========================================="
echo "  Neovim Update"
echo "========================================="
echo ""

# Update lazy.nvim plugins
echo "Updating lazy.nvim plugins..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || {
  echo "Note: Headless update failed. Run :Lazy sync inside Neovim."
}

echo ""

# Update Mason packages (LSP, linters, formatters)
echo "Updating Mason packages..."
nvim --headless "+MasonUpdate" +qa 2>/dev/null || {
  echo "Note: Mason update failed. Run :MasonUpdate inside Neovim."
}

echo ""
echo "========================================="
echo "  Neovim update complete!"
echo "========================================="
