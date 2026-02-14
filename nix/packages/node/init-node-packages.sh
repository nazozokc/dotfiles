#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
DEFAULT_NIX="default.nix"

PACKAGES=("npm" "pnpm" "npx")

echo "Initializing npm / npx / pnpm hashes in $DEFAULT_NIX..."

for pname in "${PACKAGES[@]}"; do
  echo "=== Processing $pname ==="

  version=$(npm view "$pname" version 2>/dev/null || true)
  if [[ -z "$version" ]]; then
    echo "  Could not fetch version for $pname"
    continue
  fi

  echo "  Latest version: $version"

  url="https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz"

  echo "  Fetching source hash..."
  hash=$(nix-prefetch-url --unpack "$url")
  sri=$(nix hash convert --hash-algo sha256 --to sri "$hash")
  echo "  Hash: $sri"

  echo "  Calculating npmDepsHash..."

  # 意図的に失敗させて正しい npmDepsHash を取得
  build_output=$(nix build --impure --expr "((import <nixpkgs> {}).callPackage ./. {}).\"$pname\"" 2>&1 || true)
  deps_hash=$(echo "$build_output" | grep 'got:' | awk '{print $2}' || true)

  if [[ -z "$deps_hash" ]]; then
    echo "  npmDepsHash not detected yet (will keep placeholder)"
    deps_hash="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
  else
    echo "  npmDepsHash: $deps_hash"
  fi

  # ===== 安全な置換（awk使用）=====
  awk -v pname="$pname" \
      -v version="$version" \
      -v hash="$sri" \
      -v deps="$deps_hash" '
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

  echo "  $pname initialized"
done

echo ""
echo "All packages initialized safely!"

