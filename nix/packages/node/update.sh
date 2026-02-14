#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
DEFAULT_NIX="default.nix"

# npm パッケージの list を取得（pname と npmName）
get_npm_packages() {
    awk '
    BEGIN{RS="mkNpmPackage"; FS="\n"}
    /pname *= *"/ {
        pname=""; npmName=""
        for(i=1;i<=NF;i++){
            if($i ~ /pname *= *"/){match($i,/pname *= *"([^"]+)"/,m); pname=m[1]}
            if($i ~ /npmName *= *"/){match($i,/npmName *= *"([^"]+)"/,m); npmName=m[1]}
        }
        if(pname!=""){if(npmName==""){npmName=pname}; print pname "\t" npmName}
    }' "$DEFAULT_NIX"
}

update_npm_package() {
    local pname="$1"
    local npm_name="$2"

    echo "Processing $npm_name ..."

    # version 抽出
    local current_version
    current_version=$(awk -v pname="$pname" '
        /pname *= *"/ {block=($0 ~ "pname *= *\""pname"\"")}
        block && /version *= *"/ {match($0,/version *= *"([^"]+)"/,m); print m[1]; exit}
    ' "$DEFAULT_NIX")

    if [[ -z "$current_version" ]]; then
        echo "  Could not find current version for $pname, skipping."
        return
    fi

    # npm から最新バージョン取得
    local latest_version
    latest_version=$(npm view "$npm_name" version 2>/dev/null || echo "")
    if [[ -z "$latest_version" ]]; then
        echo "  Could not fetch latest version for $npm_name, skipping."
        return
    fi

    if [[ "$current_version" != "$latest_version" ]]; then
        echo "  Updating version $current_version -> $latest_version"
        perl -0777 -pi -e "s/(pname = \"$pname\".*?version = \")$current_version/\${1}$latest_version/s" "$DEFAULT_NIX"
    else
        echo "  Already at latest version $current_version"
    fi

    # hash 更新
    local url="https://registry.npmjs.org/$npm_name/-/$pname-$latest_version.tgz"
    local new_hash=$(nix-prefetch-url --unpack "$url" 2>/dev/null)
    local new_sri=$(nix hash convert --hash-algo sha256 --to sri "$new_hash")
    perl -0777 -pi -e "s/(pname = \"$pname\".*?hash = \")sha256-[^\"]+/\${1}$new_sri/s" "$DEFAULT_NIX"

    # npmDepsHash 更新
    echo "  Calculating npmDepsHash..."
    local new_deps_hash
    new_deps_hash=$(nix build --impure --expr "((import <nixpkgs> {}).callPackage ./. {}).\"$pname\"" 2>&1 | perl -ne 'print $1 if /got:\s+(\S+)/' || true)
    if [[ -n "$new_deps_hash" ]]; then
        perl -0777 -pi -e "s/(pname = \"$pname\".*?npmDepsHash = \")sha256-[^\"]+/\${1}$new_deps_hash/s" "$DEFAULT_NIX"
    fi

    echo "  $npm_name updated!"
}

# -----------------------------
echo "Updating npm packages in $DEFAULT_NIX..."
while IFS=$'\t' read -r pname npm_name; do
    update_npm_package "$pname" "$npm_name"
done < <(get_npm_packages)

echo ""
echo "All updates done!"

