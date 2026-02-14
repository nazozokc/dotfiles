#!/usr/bin/env bash
set -euo pipefail

# ディレクトリ移動
cd "$(dirname "$0")"

DEFAULT_NIX="./default.nix"
TMP_DIR="./.tmp_node2nix"

echo "Initializing npm packages from $DEFAULT_NIX..."

# default.nix から mkNpmPackage ブロックの pname を抽出
PACKAGES=($(awk '/mkNpmPackage/ {getline; if($0 ~ /pname/){gsub(/[";]/,"",$3); print $3}}' "$DEFAULT_NIX"))

echo "Detected packages: ${PACKAGES[*]}"

mkdir -p "$TMP_DIR"

for pname in "${PACKAGES[@]}"; do
    echo "=== Processing $pname ==="

    # npm から最新バージョン取得
    version=$(npm view "$pname" version 2>/dev/null || true)
    if [[ -z "$version" ]]; then
        echo "  Could not find version for $pname, skipping."
        continue
    fi
    echo "  Version: $version"

    # 一時 package.json 作成
    PKG_JSON="$TMP_DIR/package.json"
    cat > "$PKG_JSON" <<EOF
{
  "name": "temp",
  "version": "1.0.0",
  "dependencies": {
    "$pname": "$version"
  }
}
EOF

    # node2nix で deps.nix 作成
    node2nix -i "$PKG_JSON" -o "$TMP_DIR/deps.nix" -c "$TMP_DIR/composition.nix"

    # npmDepsHash を抽出
    npmDepsHash=$(awk -F '=' '/npmDepsHash/ {gsub(/[";]/,"",$2); print $2}' "$TMP_DIR/deps.nix" | tr -d ' ')
    echo "  npmDepsHash: $npmDepsHash"

    # default.nix の hash / npmDepsHash を置換
    awk -v pname="$pname" -v version="$version" -v deps="$npmDepsHash" '
    BEGIN { inBlock=0 }
    {
        if ($0 ~ "pname[[:space:]]*=[[:space:]]*\"" pname "\"") inBlock=1
        if (inBlock && $0 ~ "version[[:space:]]*=") sub(/".*"/, "\"" version "\"")
        if (inBlock && $0 ~ "npmDepsHash[[:space:]]*=") sub(/".*"/, "\"" deps "\"")
        if (inBlock && $0 ~ "};") inBlock=0
        print
    }' "$DEFAULT_NIX" > "$DEFAULT_NIX.tmp"
    mv "$DEFAULT_NIX.tmp" "$DEFAULT_NIX"

    echo "  $pname updated in $DEFAULT_NIX"
done

# 一時ディレクトリ削除
rm -rf "$TMP_DIR"

echo ""
echo "All packages updated in $DEFAULT_NIX!"

