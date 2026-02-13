#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Updating Node packages from Nix..."

# Node packages を Nix でビルドしてシンボリックリンク
nix-shell -p nodejs-20 -p nodePackages.pnpm nodePackages.typescript nodePackages.eslint nodePackages.prettier --run '
mkdir -p '"$DOTFILES_DIR"'/node_modules/.bin
ln -sf $(which pnpm) '"$DOTFILES_DIR"'/node_modules/.bin/pnpm
ln -sf $(which tsc) '"$DOTFILES_DIR"'/node_modules/.bin/tsc
ln -sf $(which eslint) '"$DOTFILES_DIR"'/node_modules/.bin/eslint
ln -sf $(which prettier) '"$DOTFILES_DIR"'/node_modules/.bin/prettier
'

echo "Node packages updated!"

