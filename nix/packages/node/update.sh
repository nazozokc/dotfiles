#!/usr/bin/env bash
set -euo pipefail

# Usage: ./update.sh

cd "$(dirname "$0")"
DEFAULT_NIX="default.nix"

# Update hash via nix-prefetch-url
get_new_hash() {
    local pname="$1"
    local npm_name="$2"
    local version="$3"
    local url="https://registry.npmjs.org/${npm_name}/-/${pname}-${version}.tgz"
    echo "    Fetching hash for $pname..."
    nix-prefetch-url --unpack "$url"
}

# Regenerate npmDepsHash
get_new_deps_hash() {
    local pname="$1"
    local tmp_expr=$(mktemp)
    cat > "$tmp_expr" <<EOF
with import <nixpkgs> {};
callPackage ./default.nix {}
EOF
    local hash
    hash=$(nix build --expr "import ./. {}.$pname" --no-link --json | jq -r '.outputs.out')
    rm -f "$tmp_expr"
    echo "$hash"
}

# Extract package info from default.nix
packages=$(perl -0777 -ne '
  while (/mkNpmPackage\s*\{(.*?)\};/gs) {
    my $block = $1;
    my ($pname) = $block =~ /pname\s*=\s*"([^"]+)"/;
    my ($npm_name) = $block =~ /npmName\s*=\s*"([^"]+)"/;
    $npm_name //= $pname;
    my ($version) = $block =~ /version\s*=\s*"([^"]+)"/;
    print "$pname\t$npm_name\t$version\n";
  }
' "$DEFAULT_NIX")

echo "Updating npm packages..."
while IFS=$'\t' read -r pname npm_name version; do
    echo "Updating $pname..."
    
    # 最新バージョンを取得
    latest=$(npm view "$npm_name" version 2>/dev/null || echo "")
    if [[ -z $latest ]]; then
        echo "  Could not fetch latest version for $npm_name, skipping"
        continue
    fi
    if [[ $latest != "$version" ]]; then
        echo "  Updating version $version -> $latest"
        perl -pi -e "s/(pname\s*=\s*\"$pname\".*?version\s*=\s*\")$version/\${1}$latest/s" "$DEFAULT_NIX"
        version="$latest"
    else
        echo "  Already latest version $version"
    fi

    # hash 更新
    new_hash=$(get_new_hash "$pname" "$npm_name" "$version")
    perl -0777 -pi -e "s/(pname\s*=\s*\"$pname\".*?hash\s*=\s*\")sha256-[^\"]+/\${1}$new_hash/s" "$DEFAULT_NIX"

    # npmDepsHash 更新
    echo "    Updating npmDepsHash (may take a while)..."
    new_deps_hash=$(nix build --expr "import ./default.nix {}.$pname" --no-link | tail -1)
    perl -0777 -pi -e "s/(pname\s*=\s*\"$pname\".*?npmDepsHash\s*=\s*\")sha256-[^\"]+/\${1}$new_deps_hash/s" "$DEFAULT_NIX"

done <<< "$packages"

echo "All packages updated!"

