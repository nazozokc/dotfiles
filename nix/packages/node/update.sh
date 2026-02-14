#!/usr/bin/env bash
set -euo pipefail

DEFAULT_NIX="./default.nix"

echo "Initializing npm packages from $DEFAULT_NIX..."

# パッケージ名を default.nix から抽出（セミコロン除去）
PACKAGES=($(awk '/mkNpmPackage/ {getline; if ($0 ~ /pname/) { gsub(/[";]/,"",$3); print $3 }}' "$DEFAULT_NIX"))

echo "Detected packages: ${PACKAGES[*]}"

for pname in "${PACKAGES[@]}"; do
    echo "=== Processing $pname ==="

    # npm view で最新バージョン取得
    version=$(npm view "$pname" version 2>/dev/null || true)
    if [[ -z "$version" ]]; then
        echo "  Could not find version for $pname, skipping."
        continue
    fi
    echo "  Version: $version"

    # ソース URL
    url="https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz"

    # ソースハッシュを取得
    hash=$(nix-prefetch-url --unpack "$url")
    echo "  Source hash: $hash"

    # node2nix で npmDepsHash を生成（仮想ディレクトリを使って安全に）
    TMPDIR=$(mktemp -d)
    pushd "$TMPDIR" > /dev/null
    mkdir -p package
    cat > package/package.json <<EOF
{
  "name": "temp",
  "version": "1.0.0",
  "dependencies": {
    "$pname": "$version"
  }
}
EOF
    node2nix --nodejs-12 -i package/package.json -o deps.nix -c composition.nix >/dev/null
    npmDepsHash=$(awk '/npmDepsHash/ {gsub(/[";]/,"",$3); print $3}' deps.nix)
    popd > /dev/null
    rm -rf "$TMPDIR"
    echo "  npmDepsHash: $npmDepsHash"

    # default.nix を安全に書き換え
    awk -v pname="$pname" -v version="$version" -v hash="$hash" -v deps="$npmDepsHash" '
    BEGIN { inBlock=0 }
    {
        if ($0 ~ "pname[[:space:]]*=[[:space:]]*\"" pname "\"") inBlock=1
        if (inBlock && $0 ~ "version[[:space:]]*=") sub(/".*"/, "\"" version "\"")
        if (inBlock && $0 ~ "hash[[:space:]]*=") sub(/".*"/, "\"" hash "\"")
        if (inBlock && $0 ~ "npmDepsHash[[:space:]]*=") sub(/".*"/, "\"" deps "\"")
        if (inBlock && $0 ~ "};") inBlock=0
        print
    }' "$DEFAULT_NIX" > "$DEFAULT_NIX.tmp"
    mv "$DEFAULT_NIX.tmp" "$DEFAULT_NIX"

    echo "  $pname updated in $DEFAULT_NIX"
done

echo ""
echo "All packages updated in $DEFAULT_NIX!"

