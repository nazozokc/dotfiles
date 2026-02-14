#!/usr/bin/env bash
set -euo pipefail

DEFAULT_NIX="./default.nix"
TMPDIR=$(mktemp -d)

echo "Initializing npm packages from $DEFAULT_NIX..."

# default.nix からパッケージ名を自動抽出
PACKAGES=($(awk '/mkNpmPackage/ {getline; if ($0 ~ /pname/) { gsub(/[ ,"]/,"",$3); print $3 }}' "$DEFAULT_NIX"))

echo "Detected packages: ${PACKAGES[*]}"

for pname in "${PACKAGES[@]}"; do
  echo "=== Processing $pname ==="

  # version を抽出
  version=$(awk -v p="$pname" '/mkNpmPackage/ {getline; if ($0 ~ "pname.*"p) { while(getline){ if ($0 ~ "version") { gsub(/[ ,"]/,"",$3); print $3; break }}}}' "$DEFAULT_NIX")
  if [[ -z "$version" ]]; then
    echo "  Could not find version for $pname, skipping."
    continue
  fi
  echo "  Version: $version"

  # ソース tarball のハッシュ取得
  url="https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz"
  hash=$(nix-prefetch-url --unpack "$url")
  echo "  Source hash: $hash"

  # 一時 package.json 作成
  echo "{\"dependencies\": {\"$pname\": \"$version\"}}" > "$TMPDIR/package.json"

  # node2nix で composition と node-env 作成（npmDepsHash 用）
  node2nix -i "$TMPDIR/package.json" -o "$TMPDIR/node-env.nix" -c "$TMPDIR/composition.nix" --nodejs-20 >/dev/null 2>&1

  # node-env.nix から npmDepsHash 抽出
  depsHash=$(grep 'npmDepsHash' "$TMPDIR/node-env.nix" | head -n1 | awk '{print $3}' | tr -d '"')
  echo "  npmDepsHash: $depsHash"

  # default.nix を安全に更新
  awk -v p="$pname" -v v="$version" -v h="$hash" -v d="$depsHash" '
  BEGIN { inBlock=0 }
  {
    if ($0 ~ "pname.*"p) inBlock=1
    if (inBlock && $0 ~ "version") $0="    version      = \""v"\";"
    if (inBlock && $0 ~ "hash") $0="    hash         = \""h"\";"
    if (inBlock && $0 ~ "npmDepsHash") $0="    npmDepsHash  = \""d"\";"
    if (inBlock && $0 ~ "};") inBlock=0
    print
  }' "$DEFAULT_NIX" > "$DEFAULT_NIX.tmp"

  mv "$DEFAULT_NIX.tmp" "$DEFAULT_NIX"
  echo "  $pname updated in $DEFAULT_NIX"
done

rm -rf "$TMPDIR"
echo ""
echo "All packages updated in $DEFAULT_NIX!"

