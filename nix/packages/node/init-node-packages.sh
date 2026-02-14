#!/usr/bin/env bash
set -euo pipefail

# 修正版
DEFAULT_NIX="$(dirname "$0")/../../default.nix"
TMP_NIX="$(dirname "$0")/../../default.nix.tmp"

echo "Initializing npm / npx / pnpm with auto hashes from $DEFAULT_NIX..."

# 1. default.nix から mkNpmPackage の pname を抽出
PACKAGES=($(awk '/mkNpmPackage/ {p=1} p && /pname =/ {gsub(/[ ";]/,"",$3); print $3; p=0}' $DEFAULT_NIX))

for pname in "${PACKAGES[@]}"; do
  echo "=== Processing $pname ==="

  # 2. 最新バージョン取得
  version=$(npm view "$pname" version 2>/dev/null || true)
  if [[ -z "$version" ]]; then
    echo "  Could not fetch version for $pname"
    continue
  fi
  echo "  Latest version: $version"

  # 3. URL 生成
  url="https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz"

  # 4. ソースハッシュ取得
  echo "  Fetching source hash..."
  hash=$(nix-prefetch-url --unpack "$url")
  sri=$(nix hash convert --hash-algo sha256 --to sri "$hash")
  echo "  Hash: $sri"

  # 5. npmDepsHash 計算
  echo "  Calculating npmDepsHash..."
  npmDepsHash=$(nix build --impure --expr "((import <nixpkgs> {}).callPackage ./. {}).\"$pname\"" 2>&1 \
    | grep 'got:' | awk '{print $2}' || echo "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=")
  echo "  npmDepsHash: $npmDepsHash"

  # 6. default.nix に安全に反映
  awk -v pname="$pname" -v version="$version" -v hash="$sri" -v deps="$npmDepsHash" '
  BEGIN { inBlock=0 }
  {
    if ($0 ~ "pname = \"" pname "\"") inBlock=1
    if (inBlock && $0 ~ "version =") sub(/".*"/, "\"" version "\"")
    if (inBlock && $0 ~ "hash =") sub(/".*"/, "\"" hash "\"")
    if (inBlock && $0 ~ "npmDepsHash =") sub(/".*"/, "\"" deps "\"")
    if (inBlock && $0 ~ "};") inBlock=0
    print
  }' "$DEFAULT_NIX" > "$TMP_NIX"

  mv "$TMP_NIX" "$DEFAULT_NIX"
  echo "  $pname updated in default.nix"
done

echo ""
echo "All packages initialized and updated successfully!"

