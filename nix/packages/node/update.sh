#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
DEFAULT_NIX="default.nix"

echo "Initializing npm packages from $DEFAULT_NIX..."

# --- default.nix から npm パッケージ名だけ抽出 ---
mapfile -t PKGS < <(
    awk '/mkNpmPackage/ {inBlock=1} 
         inBlock && /pname *=/ {gsub(/[ ";]/,""); print $3; inBlock=0}' "$DEFAULT_NIX"
)

echo "Detected packages: ${PKGS[*]}"

# --- 各パッケージを更新 ---
for pkg in "${PKGS[@]}"; do
    echo "=== Processing $pkg ==="

    # 現在のバージョンを default.nix から取得
    current_version=$(awk -v p="$pkg" '
        $0 ~ "pname *= *\""p"\"" {
            for(i=1;i<=5;i++){getline; if($0 ~ /version *=/){gsub(/[ ";]/,"",$3); print $3; exit}}
        }' "$DEFAULT_NIX")

    if [[ -z "$current_version" ]]; then
        echo "  Could not find version for $pkg, skipping."
        continue
    fi

    # npm から最新バージョン取得
    latest_version=$(npm view "$pkg" version 2>/dev/null || true)
    if [[ -z "$latest_version" ]]; then
        echo "  Could not fetch latest version for $pkg, skipping."
        continue
    fi

    if [[ "$current_version" == "$latest_version" ]]; then
        echo "  Already at latest version: $current_version"
        continue
    fi

    echo "  Updating from $current_version -> $latest_version"

    # 新しい tarball の URL
    url="https://registry.npmjs.org/${pkg}/-/${pkg}-${latest_version}.tgz"

    # ソースハッシュ取得
    new_hash=$(nix-prefetch-url --unpack "$url")
    new_sri=$(nix hash convert --hash-algo sha256 --to sri "$new_hash")

    # default.nix を直接書き換え
    perl -0777 -pi -e "
        s/(pname *= *\"$pkg\".*?version *= *\")$current_version(\")/$1$latest_version$2/s;
        s/(pname *= *\"$pkg\".*?hash *= *\")[^\"]+/$1$new_sri/s;
    " "$DEFAULT_NIX"

    echo "  $pkg updated in $DEFAULT_NIX"
done

echo ""
echo "All packages updated in $DEFAULT_NIX!"

