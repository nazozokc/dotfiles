#!/usr/bin/env bash
set -euo pipefail

DEFAULT_NIX="./default.nix"
TMP_DIR="$(mktemp -d)"
NODE2NIX_DIR="${TMP_DIR}/node2nix"

mkdir -p "$NODE2NIX_DIR"

echo "Initializing npm packages from $DEFAULT_NIX..."

# 1. default.nix からパッケージ名を抽出
PKGS=($(awk '/mkNpmPackage/{getline; gsub(/.*pname[ ]*=[ ]*"/,""); gsub(/".*/,""); print $0}' "$DEFAULT_NIX"))
echo "Detected packages: ${PKGS[*]}"

for PKG in "${PKGS[@]}"; do
    echo "=== Processing $PKG ==="

    VERSION=$(npm view "$PKG" version 2>/dev/null || true)
    if [[ -z "$VERSION" ]]; then
        echo "  Could not find version for $PKG, skipping."
        continue
    fi
    echo "  Version: $VERSION"

    # fetchurl hash
    URL="https://registry.npmjs.org/${PKG}/-/${PKG}-${VERSION}.tgz"
    HASH=$(nix-prefetch-url --unpack "$URL")
    echo "  Source hash: $HASH"

    # node2nix 用 package.json を一時作成
    echo "{\"name\":\"tmp\",\"version\":\"1.0.0\",\"dependencies\":{\"$PKG\":\"$VERSION\"}}" > "$NODE2NIX_DIR/package.json"

    # node2nix 実行して node-env.nix を生成
    node2nix --input "$NODE2NIX_DIR/package.json" --node-env "$NODE2NIX_DIR/node-env.nix" --composition "$NODE2NIX_DIR/composition.nix" >/dev/null

    # node-env.nix から npmDepsHash を抽出
    NPMDEPSHASH=$(awk -F'"' "/$PKG/{getline; getline; gsub(/.*\"/,\"\", \$0); gsub(/\"/,\"\", \$0); print \$0}" "$NODE2NIX_DIR/node-env.nix" || true)
    echo "  npmDepsHash: $NPMDEPSHASH"

    # default.nix に反映
    awk -v pkg="$PKG" -v version="$VERSION" -v hash="$HASH" -v deps="$NPMDEPSHASH" '
    BEGIN{inBlock=0}
    {
      if ($0 ~ "pname[ ]*=[ ]*\"" pkg "\"") inBlock=1
      if (inBlock && $0 ~ "version") sub(/".*"/, "\"" version "\"")
      if (inBlock && $0 ~ "hash") sub(/".*"/, "\"" hash "\"")
      if (inBlock && $0 ~ "npmDepsHash") sub(/".*"/, "\"" deps "\"")
      if (inBlock && $0 ~ "};") inBlock=0
      print
    }' "$DEFAULT_NIX" > "$DEFAULT_NIX.tmp"

    mv "$DEFAULT_NIX.tmp" "$DEFAULT_NIX"
    echo "  $PKG updated in $DEFAULT_NIX"
done

rm -rf "$TMP_DIR"
echo "All packages updated in $DEFAULT_NIX!"

