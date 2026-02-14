#!/usr/bin/env bash
set -euo pipefail

# default.nix があるディレクトリに移動
cd "$(dirname "$0")"
DEFAULT_NIX="./default.nix"

echo "Updating npm / npx / pnpm packages in $DEFAULT_NIX with node2nix..."

# default.nix から mkNpmPackage ブロック内のパッケージ名を抽出
PACKAGES=($(awk '/mkNpmPackage/ {match($0,/pname = "([^"]+)"/,a); print a[1]}' "$DEFAULT_NIX"))

for PNAME in "${PACKAGES[@]}"; do
    echo "=== Processing $PNAME ==="

    # 最新バージョン取得
    VERSION=$(npm view "$PNAME" version 2>/dev/null || true)
    if [[ -z "$VERSION" ]]; then
        echo "  Could not fetch version for $PNAME, skipping."
        continue
    fi
    echo "  Latest version: $VERSION"

    # node2nix で一時的に npmDepsHash を生成
    TMP_DIR=$(mktemp -d)
    echo "  Running node2nix for $PNAME..."
    mkdir -p "$TMP_DIR/$PNAME"
    pushd "$TMP_DIR/$PNAME" > /dev/null
    npm init -y >/dev/null 2>&1
    npm install "$PNAME@$VERSION" >/dev/null 2>&1
    node2nix -i package.json -o node-packages.nix -c composition.nix >/dev/null
    NPM_DEPS_HASH=$(awk '/npmDepsHash/ {gsub(/"/,""); print $3}' node-packages.nix)
    popd > /dev/null
    rm -rf "$TMP_DIR"

    # ソースの tarball hash 取得
    URL="https://registry.npmjs.org/${PNAME}/-/${PNAME}-${VERSION}.tgz"
    HASH=$(nix-prefetch-url --unpack "$URL")
    SRI=$(nix hash convert --hash-algo sha256 --to sri "$HASH")

    # default.nix の hash と npmDepsHash を置換
    awk -v pname="$PNAME" -v version="$VERSION" -v hash="$SRI" -v deps="$NPM_DEPS_HASH" '
    BEGIN { inBlock=0 }
    {
        if ($0 ~ "pname = \"" pname "\"") inBlock=1
        if (inBlock && $0 ~ "version =") sub(/".*"/, "\"" version "\"")
        if (inBlock && $0 ~ "hash =") sub(/".*"/, "\"" hash "\"")
        if (inBlock && $0 ~ "npmDepsHash =") sub(/".*"/, "\"" deps "\"")
        if (inBlock && $0 ~ "};") inBlock=0
        print
    }' "$DEFAULT_NIX" > "$DEFAULT_NIX.tmp"

    mv "$DEFAULT_NIX.tmp" "$DEFAULT_NIX"
    echo "  $PNAME updated"
done

echo "All packages updated in $DEFAULT_NIX!"

