#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────
# Node.js パッケージの hash / npmDepsHash を自動更新するスクリプト
# default.nix 内の pname = "..." を自動で抽出
# ──────────────────────────────

DEFAULT_NIX="./default.nix"

echo "Initializing npm packages from $DEFAULT_NIX..."

# default.nix から pname のみ抽出
PACKAGES=($(grep -oP 'pname\s*=\s*"\K[^"]+' "$DEFAULT_NIX"))

if [[ ${#PACKAGES[@]} -eq 0 ]]; then
    echo "No packages detected in $DEFAULT_NIX!"
    exit 1
fi

echo "Detected packages: ${PACKAGES[*]}"

for PNAME in "${PACKAGES[@]}"; do
    echo "=== Processing $PNAME ==="

    # default.nix から現在のバージョンを取得
    VERSION=$(grep -A1 "pname\s*=\s*\"$PNAME\"" "$DEFAULT_NIX" | grep 'version' | grep -oP '"\K[^"]+')
    if [[ -z "$VERSION" ]]; then
        echo "  Could not find version for $PNAME, skipping."
        continue
    fi
    echo "  Version: $VERSION"

    # npm パッケージをダウンロードして source hash 取得
    URL="https://registry.npmjs.org/${PNAME}/-/${PNAME}-${VERSION}.tgz"
    HASH=$(nix-prefetch-url --unpack "$URL")
    SRI=$(nix hash convert --hash-algo sha256 --to sri "$HASH")
    echo "  Source hash: $SRI"

    # node2nix で npmDepsHash 取得
    echo "  Calculating npmDepsHash via node2nix..."
    TMP_DIR=$(mktemp -d)
    pushd "$TMP_DIR" > /dev/null

    # 仮 package.json 作成
    echo "{\"name\":\"tmp\",\"version\":\"1.0.0\",\"dependencies\":{\"$PNAME\":\"$VERSION\"}}" > package.json

    # node2nix 実行
    node2nix -i package.json -o node-packages.nix -c composition.nix

    # npmDepsHash を抽出
    NPMDEPSHASH=$(grep -A1 "$PNAME" node-packages.nix | grep npmDepsHash | grep -oP '"\K[^"]+')
    echo "  npmDepsHash: $NPMDEPSHASH"

    popd > /dev/null
    rm -rf "$TMP_DIR"

    # default.nix を安全に更新
    awk -v pname="$PNAME" -v version="$VERSION" -v hash="$SRI" -v deps="$NPMDEPSHASH" '
    BEGIN { inBlock=0 }
    {
        if ($0 ~ "pname[[:space:]]*=[[:space:]]*\""pname"\"") inBlock=1
        if (inBlock && $0 ~ "version[[:space:]]*=") sub(/".*"/, "\""version"\"")
        if (inBlock && $0 ~ "hash[[:space:]]*=") sub(/".*"/, "\""hash"\"")
        if (inBlock && $0 ~ "npmDepsHash[[:space:]]*=") sub(/".*"/, "\""deps"\"")
        if (inBlock && $0 ~ "};") inBlock=0
        print
    }' "$DEFAULT_NIX" > "$DEFAULT_NIX.tmp"

    mv "$DEFAULT_NIX.tmp" "$DEFAULT_NIX"
    echo "  $PNAME updated in $DEFAULT_NIX!"
done

echo "All packages updated in $DEFAULT_NIX!"

