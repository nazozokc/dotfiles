#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
DEFAULT_NIX="./default.nix"

echo "Initializing npm / npx / pnpm with node2nix hashes in $DEFAULT_NIX..."

# 1. package.json を作る（存在しなければ生成）
if [ ! -f package.json ]; then
  echo '{"name":"temp","version":"1.0.0","dependencies":{"npm":"11.10.0","npx":"10.2.2","pnpm":"10.29.3"}}' > package.json
fi

# 2. node2nix で依存を解決
node2nix -i package.json -o node-packages.nix -c composition.nix

# 3. default.nix の mkNpmPackage ブロックを更新
for pname in $(awk '/pname =/ {gsub(/[ ";]/,""); print $3}' "$DEFAULT_NIX"); do
  version=$(jq -r ".dependencies[\"$pname\"]" package.json)
  hash=$(nix-prefetch-url "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz")
  npmDepsHash=$(nix hash file ./composition.nix --type sha256)

  echo "Updating $pname: version=$version, hash=$hash, npmDepsHash=$npmDepsHash"

  awk -v pname="$pname" -v version="$version" -v hash="$hash" -v deps="$npmDepsHash" '
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
done

echo "All packages updated successfully!"

