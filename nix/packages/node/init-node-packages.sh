#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
DEFAULT_NIX="default.nix"

PACKAGES=("npm" "pnpm" "npx")

echo "Initializing npm / npx / pnpm hashes in $DEFAULT_NIX..."

for pname in "${PACKAGES[@]}"; do
  echo "=== Processing $pname ==="

  # 最新バージョン取得
  version=$(npm view "$pname" version 2>/dev/null || true)
  if [[ -z "$version" ]]; then
    echo "  Could not fetch version for $pname, skipping"
    continue
  fi
  echo "  Latest version: $version"

  # ソース取得して hash 計算
  url="https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz"
  echo "  Fetching source hash for $url..."
  hash=$(nix-prefetch-url --unpack "$url")
  sri=$(nix hash convert --hash-algo sha256 --to sri "$hash")
  echo "  Hash: $sri"

  # npmDepsHash 計算（mkNpmPackage 用）
  echo "  Calculating npmDepsHash (this may take a few seconds)..."
  deps_hash=$(nix build --impure --expr "((import <nixpkgs> {}).callPackage ./. {}).\"$pname\"" 2>&1 | perl -ne 'print $1 if /got:\s+(\S+)/' || true)
  echo "  npmDepsHash: $deps_hash"

  # default.nix に書き込む
  perl -0777 -pi -e "
    if (/mkNpmPackage\s*\{.*?pname\s*=\s*\"$pname\"/s) {
      s/(version\s*=\s*\")[^\"]+/\$1$version/;
      s/(hash\s*=\s*\")[^\"]+/\$1$sri/;
      s/(npmDepsHash\s*=\s*\")[^\"]+/\$1$deps_hash/;
    }
  " "$DEFAULT_NIX"

  echo "  $pname initialized"
done

echo ""
echo "All packages initialized in default.nix!"

