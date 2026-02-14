#!/usr/bin/env bash
set -euo pipefail

# スクリプト自身のあるディレクトリを基準に default.nix を指定
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_NIX="$SCRIPT_DIR/default.nix"

if [[ ! -f "$DEFAULT_NIX" ]]; then
    echo "Error: default.nix not found in $SCRIPT_DIR"
    exit 1
fi

# Node / npm / pnpm / CLI ツールのリスト
PACKAGES=("npm" "npx" "pnpm" "npm-cli-tool" "pnpm-cli-tools" "npx-cli-tools")

update_package() {
    local pkg="$1"
    local version
    local hash
    local deps_hash

    echo "=== Updating $pkg ==="

    # まず default.nix からバージョンを取得
    version=$(grep -A3 "pname = \"$pkg\"" "$DEFAULT_NIX" | grep version | perl -pe 's/.*"([^"]+)".*/$1/')

    if [[ -z "$version" ]]; then
        echo "  Could not find version for $pkg, skipping."
        return
    fi

    echo "  Version: $version"

    # URL を生成
    url="https://registry.npmjs.org/$pkg/-/$pkg-$version.tgz"

    # hash を取得
    echo "  Fetching source hash..."
    hash=$(nix-prefetch-url --unpack "$url")
    echo "  hash=$hash"

    # npmDepsHash を取得
    echo "  Calculating npmDepsHash..."
    deps_hash=$(nix build --impure --expr "((import <nixpkgs> {}).callPackage ./. {}).\"$pkg\"" 2>&1 | grep -oP 'got: \K\S+')
    echo "  npmDepsHash=$deps_hash"

    # default.nix を更新
    perl -0777 -pi -e "s/(pname = \"$pkg\".*?hash = \")sha256-[^\"]+/\${1}$hash/s" "$DEFAULT_NIX"
    perl -0777 -pi -e "s/(pname = \"$pkg\".*?npmDepsHash = \")sha256-[^\"]+/\${1}$deps_hash/s" "$DEFAULT_NIX"

    echo "  Updated $pkg!"
}

for pkg in "${PACKAGES[@]}"; do
    update_package "$pkg"
done

echo "All packages updated!"

