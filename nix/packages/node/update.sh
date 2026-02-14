#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

DEFAULT_NIX="default.nix"
NODE_MODULES_DIR="node_modules"

mkdir -p "$NODE_MODULES_DIR"

# 現在のバージョン取得
get_current_version() {
    local pkg="$1"
    perl -0777 -ne "if (/^\s+$pkg\s*=\s*mkNpmPackage\s*\{[^}]*version\s*=\s*\"([^\"]+)\"/m) { print \$1; }" "$DEFAULT_NIX"
}

# 最新バージョン取得
get_latest_version() {
    local pkg="$1"
    npm view "$pkg" version --json 2>/dev/null | tr -d '"'
}

# SRI ハッシュ取得
get_sri_hash() {
    local url="$1"
    nix hash to-sri --type sha256 "$(nix-prefetch-url "$url" 2>/dev/null)" 2>/dev/null
}

# npmDepsHash 計算
get_npmDepsHash() {
    local pkg="$1"
    nix build ".#${pkg}" --json 2>/dev/null | grep -oP '"narHash":\s*"\K[^"]+' | head -1 || true
}

update_npm_package() {
    local pkg="$1"
    local current_version="$2"
    local latest_version="$3"

    echo "Processing $pkg ($current_version -> $latest_version)"

    if [[ "$current_version" != "$latest_version" ]]; then
        # tarball URL
        local tarball_url="https://registry.npmjs.org/${pkg}/-/${pkg}-${latest_version}.tgz"
        local new_hash
        new_hash=$(get_sri_hash "$tarball_url")

        # default.nix 更新
        perl -i -pe "s/(^\s+$pkg\s*=\s*mkNpmPackage\s*\{[^}]*version\s*=\")([^\"]+)(\".*)/\$1${latest_version}\$3/m" "$DEFAULT_NIX"
        perl -i -pe "s/(^\s+$pkg\s*=\s*mkNpmPackage\s*\{[^}]*hash\s*=\")[^\"]+(\".*)/\$1${new_hash}\$2/m" "$DEFAULT_NIX"

        echo "  Updated version and hash in default.nix"

        # npmDepsHash 更新
        local deps_hash
        deps_hash=$(get_npmDepsHash "$pkg")
        if [[ -n "$deps_hash" ]]; then
            perl -i -pe "s/(^\s+$pkg\s*=\s*mkNpmPackage\s*\{[^}]*npmDepsHash\s*=\")[^\"]*(\".*)/\$1${deps_hash}\$2/m" "$DEFAULT_NIX"
            echo "  Updated npmDepsHash in default.nix"
        fi

        # npm install
        echo "  Installing $pkg@$latest_version locally..."
        npm install --prefix "$NODE_MODULES_DIR" "$pkg@$latest_version" --ignore-scripts --no-package-lock >/dev/null
        echo "  Installed $pkg@$latest_version"
    else
        echo "  Already up to date"
    fi
}

# パッケージ一覧
packages=$(grep -oP '^\s+\w+\s*=\s*mkNpmPackage' "$DEFAULT_NIX" | grep -oP '^\s+\K\w+')

echo "=== npm package update started ==="
for pkg in $packages; do
    current=$(get_current_version "$pkg")
    latest=$(get_latest_version "$pkg")
    update_npm_package "$pkg" "$current" "$latest"
done
echo "=== npm package update completed ==="

