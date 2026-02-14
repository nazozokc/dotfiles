#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

DEFAULT_NIX="default.nix"

get_npm_packages() {
    grep -oP '^\s+\w+\s*=\s*mkNpmPackage\s*{' "$DEFAULT_NIX" | grep -oP '^\s+\K\w+'
}

get_current_version() {
    local pkg="$1"
    perl -0777 -ne "if (/^\s+$pkg\s*=\s*mkNpmPackage\s*\{[^}]*version\s*=\s*\"([^\"]+)\"/m) { print \$1; }" "$DEFAULT_NIX"
}

get_latest_version() {
    local pkg="$1"
    npm view "$pkg" version --json 2>/dev/null | tr -d '"'
}

get_sri_hash() {
    local url="$1"
    nix hash to-sri --type sha256 "$(nix-prefetch-url "$url" 2>/dev/null)" 2>/dev/null
}

update_npm_package() {
    local pkg="$1"
    local current_version="$2"
    local latest_version="$3"

    echo "Updating $pkg: $current_version -> $latest_version"

    if [[ "$current_version" != "$latest_version" ]]; then
        local tarball_url="https://registry.npmjs.org/${pkg}/-/${pkg}-${latest_version}.tgz"
        local new_hash
        new_hash=$(get_sri_hash "$tarball_url")

        perl -i -pe "s/(^\s+$pkg\s*=\s*mkNpmPackage\s*\{[^}]*version\s*=\s*\")([^\"]+)(\".*)/\$1${latest_version}\$3/m" "$DEFAULT_NIX"
        perl -i -pe "s/(^\s+$pkg\s*=\s*mkNpmPackage\s*\{[^}]*hash\s*=\s*\")[^\"]+(\".*)/\$1${new_hash}\$3/m" "$DEFAULT_NIX"

        echo "  Updated version and hash for $pkg"

        local npm_deps_hash
        npm_deps_hash=$(nix build ".#${pkg}" --json 2>/dev/null | grep -oP '"narHash":\s*"\K[^"]+' | head -1 || true)

        if [[ -n "$npm_deps_hash" ]]; then
            perl -i -pe "s/(^\s+$pkg\s*=\s*mkNpmPackage\s*\{[^}]*npmDepsHash\s*=\s*\")[^\"]*(\".*)/\$1${npm_deps_hash}\$3/m" "$DEFAULT_NIX"
            echo "  Updated npmDepsHash for $pkg"
        fi
    else
        echo "  Already up to date"
    fi
}

echo "=== npm package update started ==="
echo ""

packages=$(get_npm_packages)

for pkg in $packages; do
    current=$(get_current_version "$pkg")
    latest=$(get_latest_version "$pkg")
    update_npm_package "$pkg" "$current" "$latest"
done

echo ""
echo "=== npm package update completed ==="
