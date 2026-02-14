#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

DEFAULT_NIX="./default.nix"
TMP_DIR="$(mktemp -d)"
PACKAGES=()

echo "Initializing npm / npx / pnpm hashes from default.nix..."

# 1️⃣ default.nix からパッケージ名を抽出
while IFS= read -r line; do
  pname=$(echo "$line" | awk -F'[ =;]+' '/mkNpmPackage/ {gsub(/"/,"",$2); print $2}')
  [[ -n "$pname" ]] && PACKAGES+=("$pname")
done < "$DEFAULT_NIX"

echo "Detected packages: ${PACKAGES[*]}"

# 2️⃣ 各パッケージを node2nix で処理して hash と npmDepsHash を取得
for pname in "${PACKAGES[@]}"; do
  echo "=== Processing $pname ==="
  version=$(nix eval --raw "import <nixpkgs> {}.$pname.version" || true)
  [[ -z "$version" ]] && version=$(npm view "$pname" version)

  echo "  Version: $version"

  URL="https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz"

  # fetchurl で hash を取得
  hash=$(nix-prefetch-url --unpack "$URL")
  sri=$(nix hash convert --hash-algo sha256 --to sri "$hash")
  echo "  hash: $sri"

  # node2nix で npmDepsHash を生成
  pushd "$TMP_DIR" >/dev/null
  rm -rf node-packages.nix
  node2nix -i <(echo "{}") -o node-packages.nix -c composition.nix >/dev/null 2>&1
  depsHash=$(awk -F'"' "/$pname/ {getline; getline; if(\$1 ~ /npmDepsHash/) print \$2}" node-packages.nix)
  popd >/dev/null

  [[ -z "$depsHash" ]] && depsHash="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
  echo "  npmDepsHash: $depsHash"

  # 3️⃣ default.nix を書き換え
  awk -v pname="$pname" -v hash="$sri" -v deps="$depsHash" '
  BEGIN { inBlock=0 }
  {
    if ($0 ~ "pname[ ]*=[ ]*\"" pname "\"") inBlock=1
    if (inBlock && $0 ~ "hash[ ]*=") sub(/".*"/, "\"" hash "\"")
    if (inBlock && $0 ~ "npmDepsHash[ ]*=") sub(/".*"/, "\"" deps "\"")
    if (inBlock && $0 ~ "};") inBlock=0
    print
  }' "$DEFAULT_NIX" > "$DEFAULT_NIX.tmp"

  mv "$DEFAULT_NIX.tmp" "$DEFAULT_NIX"
  echo "  $pname updated in default.nix"
done

echo "All packages updated in $DEFAULT_NIX!"

