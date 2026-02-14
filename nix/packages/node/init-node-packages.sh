#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
DEFAULT_NIX="default.nix"

PACKAGES=("npm" "pnpm" "npx")

echo "Initializing npm / npx / pnpm with node2nix hashes in $DEFAULT_NIX..."

for pname in "${PACKAGES[@]}"; do
  echo "=== Processing $pname ==="

  # 最新バージョンを取得
  version=$(npm view "$pname" version 2>/dev/null || true)
  if [[ -z "$version" ]]; then
    echo "  Could not fetch version for $pname"
    continue
  fi
  echo "  Latest version: $version"

  # 一時ディレクトリ作成
  tmpdir=$(mktemp -d)
  cd "$tmpdir"

  # package.json を簡易生成
  cat > package.json <<EOF
{
  "name": "temp-$pname",
  "version": "1.0.0",
  "dependencies": {
    "$pname": "$version"
  }
}
EOF

  # node2nix で npmDepsHash を生成
  echo "  Running node2nix..."
  nix run nixpkgs#node2nix -- generate -i package.json -o node-packages.nix -c composition.nix -f

  # 生成された default.nix を読んで npmDepsHash を抽出
  deps_hash=$(grep -Po '(?<=npmDepsHash = ").*?(?=")' node-packages.nix)
  if [[ -z "$deps_hash" ]]; then
    echo "  Failed to detect npmDepsHash, using placeholder"
    deps_hash="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
  else
    echo "  npmDepsHash detected: $deps_hash"
  fi

  # source hash 取得
  url="https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz"
  hash=$(nix-prefetch-url --unpack "$url")
  sri=$(nix hash convert --hash-algo sha256 --to sri "$hash")
  echo "  Source hash: $sri"

  # default.nix を安全に置換
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
  }' "$OLDPWD/$DEFAULT_NIX" > "$OLDPWD/$DEFAULT_NIX.tmp"

  mv "$OLDPWD/$DEFAULT_NIX.tmp" "$OLDPWD/$DEFAULT_NIX"
  echo "  $pname initialized"

  cd "$OLDPWD"
  rm -rf "$tmpdir"
done

echo ""
echo "All packages initialized with node2nix!"

