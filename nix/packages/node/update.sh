#!/usr/bin/env bash
set -euo pipefail

# -------------------------------
# Nixで管理するNode / npm CLI 更新
# -------------------------------

# dotfiles の packages/node ディレクトリ
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Updating Node packages from Nix..."

# Nodeパッケージ読み込み
NODE_PKGS=$(nix eval --raw "${DOTFILES_DIR}/default.nix" | tr '\n' ' ')

# node_modules ディレクトリ
NODE_MODULES="${DOTFILES_DIR}/node_modules"

# 古い node_modules は削除
rm -rf "$NODE_MODULES"
mkdir -p "$NODE_MODULES"

# 各 CLI をシンボリックリンクで配置
for pkg in $NODE_PKGS; do
    BIN_DIR="$NODE_MODULES/.bin"
    mkdir -p "$BIN_DIR"
    
    BIN_PATH=$(nix eval --raw "$pkg.bin")
    
    if [[ -n "$BIN_PATH" ]]; then
        ln -sf "$BIN_PATH" "$BIN_DIR/$(basename "$BIN_PATH")"
        echo "Linked $(basename "$BIN_PATH")"
    fi
done

echo "Node packages updated!"

