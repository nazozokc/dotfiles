#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# update.sh for npm packages in default.nix
# Updates version, hash, and npmDepsHash automatically
# -----------------------------

cd "$(dirname "$0")"
DEFAULT_NIX="default.nix"

# -----------------------------
# Extract package list from default.nix
# -----------------------------
get_npm_packages() {
    perl -0777 -ne '
        while (/mkNpmPackage\s*\{(.*?)\};/sg) {
            my $block = $1;
            my ($pname) = $block =~ /pname\s*=\s*"([^"]+)"/s;
            my ($npm_name) = $block =~ /npmName\s*=\s*"([^"]+)"/s;
            $npm_name //= $pname;
            print "$pname\t$npm_name\n";
        }
    ' "$DEFAULT_NIX"
}

# -----------------------------
# Update a single npm package
# -----------------------------
update_npm_package() {
    local pname="$1"
    local npm_name="$2"

    echo "Processing $npm_name ..."

    # 現在の version を取得
    local current_version
    current_version=$(perl -0777 -ne "print \$1 if /pname = \"$pname\".*?version = \"([^\"]+)\"/s" "$DEFAULT_NIX")
    if [[ -z "$current_version" ]]; then
        echo "  Could not find current version for $pname, skipping."
        return
    fi

    # npm から最新バージョンを取得
    local latest_version
    latest_version=$(npm view "$npm_name" version 2>/dev/null || echo "")
    if [[ -z "$latest_version" ]]; then
        echo "  Could not fetch latest version for $npm_name, skipping."
        return
    fi

    if [[ "$current_version" == "$latest_version" ]]; then
        echo "  Already at latest version: $current_version"
    else
        echo "  Updating version: $current_version -> $latest_version"
        perl -0777 -pi -e "s/(pname = \"$pname\".*?version = \")$current_version/\${1}$latest_version/s" "$DEFAULT_NIX"
    fi

    # 新しい hash を取得
    local url="https://registry.npmjs.org/$npm_name/-/$pname-$latest_version.tgz"
    echo "  Fetching new hash..."
    local new_hash
    new_hash=$(nix-prefetch-url --unpack "$url" 2>/dev/null)
    local new_sri
    new_sri=$(nix hash convert --hash-algo sha256 --to sri "$new_hash")
    perl -0777 -pi -e "s/(pname = \"$pname\".*?hash = \")sha256-[^\"]+/\${1}$new_sri/s" "$DEFAULT_NIX"

    # npmDepsHash を自動計算
    echo "  Calculating npmDepsHash (may take a while)..."
    local new_deps_hash
    new_deps_hash=$(nix build --impure --expr "((import <nixpkgs> {}).callPackage ./. {}).\"$pname\"" 2>&1 | perl -ne 'print $1 if /got:\s+(\S+)/' || true)
    if [[ -n "$new_deps_hash" ]]; then
        perl -0777 -pi -e "s/(pname = \"$pname\".*?npmDepsHash = \")sha256-[^\"]+/\${1}$new_deps_hash/s" "$DEFAULT_NIX"
    fi

    echo "  $npm_name updated successfully!"
}

# -----------------------------
# Main loop
# -----------------------------
echo "Updating npm packages in $DEFAULT_NIX..."
while IFS=$'\t' read -r pname npm_name; do
    update_npm_package "$pname" "$npm_name"
done < <(get_npm_packages)

echo ""
echo "All updates done!"

