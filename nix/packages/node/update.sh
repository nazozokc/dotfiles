#!/usr/bin/env bash
set -euo pipefail

DEFAULT_NIX="./default.nix"
TEMP_NIX="./default.nix.tmp"

echo "Initializing npm packages from $DEFAULT_NIX..."

# mkNpmPackage ブロックからパッケージ名を抽出
packages=($(awk '
  $0 ~ /mkNpmPackage *{/ {inBlock=1}
  inBlock && $0 ~ /pname *=/ {
    gsub(/[ ;"]/,"",$3)
    print $3
    inBlock=0
  }' "$DEFAULT_NIX"))

echo "Detected packages: ${packages[*]}"

for pname in "${packages[@]}"; do
  echo "=== Processing $pname ==="

  # npm から最新バージョンを取得
  version=$(npm view "$pname" version 2>/dev/null)
  echo "  Version: $version"

  # ソースURL
  url="https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz"

  # source hash を取得
  hash=$(nix-prefetch-url --unpack "$url")
  echo "  Source hash: $hash"

  # npmDepsHash を計算（node2nix を利用）
  echo "  Calculating npmDepsHash via node2nix..."
  node2nixOutput=$(node2nix -i <(echo "{}") -o /dev/null -c /dev/null --nodejs-20 -p "$pname@$version" 2>&1)
  depsHash=$(echo "$node2nixOutput" | grep "npmDepsHash" | awk '{print $2}' || echo "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
  echo "  npmDepsHash: $depsHash"

  # default.nix を置換
  awk -v pname="$pname" -v version="$version" -v hash="$hash" -v deps="$depsHash" '
  BEGIN {inBlock=0}
  {
    if ($0 ~ "mkNpmPackage" && $0 ~ pname) inBlock=1
    if (inBlock && $0 ~ "version *= *") sub(/".*"/, "\"" version "\"")
    if (inBlock && $0 ~ "hash *= *") sub(/".*"/, "\"" hash "\"")
    if (inBlock && $0 ~ "npmDepsHash *= *") sub(/".*"/, "\"" deps "\"")
    if (inBlock && $0 ~ "};") inBlock=0
    print
  }' "$DEFAULT_NIX" > "$TEMP_NIX"

  mv "$TEMP_NIX" "$DEFAULT_NIX"

  echo "  $pname updated"
done

echo "All packages updated in $DEFAULT_NIX!"

