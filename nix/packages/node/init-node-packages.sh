#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

DEFAULT_NIX="default.nix"
PKG_JSON="package.json"
NODE2NIX_OUT="node-packages.nix"
NODE2NIX_COMPOSITION="composition.nix"

PACKAGES=("npm" "npx" "pnpm")

echo "Initializing npm / npx / pnpm with node2nix hashes in $DEFAULT_NIX..."

# node2nix 用 package.json を作成
# 実際に使いたいパッケージとバージョンをここに定義
cat > "$PKG_JSON" <<EOF
{
  "name": "nazozo-node-tools",
  "version": "1.0.0",
  "dependencies": {
    "npm": "latest",
    "npx": "latest",
    "pnpm": "latest"
  }
}
EOF

# node2nix で Nix パッケージ生成
echo "=== Running node2nix ==="
nix run nixpkgs#node2nix -- generate -i "$PKG_JSON" -o "$NODE2NIX_OUT" -c "$NODE2NIX_COMPOSITION"

# node-packages.nix から各パッケージのハッシュを抽出して default.nix に書き込む
for pname in "${PACKAGES[@]}"; do
  version=$(jq -r ".dependencies[\"$pname\"]" "$PKG_JSON")
  hash=$(grep -A1 "name = \"$pname\";" "$NODE2NIX_OUT" | grep "npmDepsHash =" | awk '{print $3}' | tr -d '";')

  echo "=== Processing $pname ==="
  echo "  Version: $version"
  echo "  npmDepsHash: $hash"

  # default.nix の該当ブロックを書き換え
  awk -v pname="$pname" -v deps="$hash" '
  BEGIN { inBlock=0 }
  {
    if ($0 ~ "pname = \"" pname "\"") inBlock=1
    if (inBlock && $0 ~ "npmDepsHash =") sub(/".*"/, "\"" deps "\"")
    if (inBlock && $0 ~ "};") inBlock=0
    print
  }' "$DEFAULT_NIX" > "$DEFAULT_NIX.tmp"

  mv "$DEFAULT_NIX.tmp" "$DEFAULT_NIX"
done

# cleanup
rm "$PKG_JSON"

echo ""
echo "All Node.js packages initialized with node2nix hashes in $DEFAULT_NIX!"

