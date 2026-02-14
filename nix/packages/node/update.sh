#!/usr/bin/env bash
set -euo pipefail

# update.sh: Node / npm CLI packages version + hash + npmDepsHash auto update

cd "$(dirname "$0")"

DEFAULT_NIX="./default.nix"

# Update source hash and npmDepsHash for one package
update_package() {
  local pname="$1"
  local npm_name="$2"

  echo "Updating $npm_name..."

  # Current version
  local current_version
  current_version=$(perl -ne "print \$1 if /pname = \"$pname\".*?version = \"([^\"]+)\"/s" "$DEFAULT_NIX")

  if [[ -z "$current_version" ]]; then
    echo "  Cannot find version for $pname"
    return
  fi

  # Latest version from npm
  local latest_version
  latest_version=$(npm view "$npm_name" version 2>/dev/null)

  if [[ -z "$latest_version" ]]; then
    echo "  Cannot fetch latest version for $npm_name"
    return
  fi

  if [[ "$current_version" == "$latest_version" ]]; then
    echo "  Already latest version: $current_version"
  else
    echo "  Updating version $current_version -> $latest_version"
    perl -0777 -pi -e "s/(pname = \"$pname\".*?version = \")$current_version/\$1$latest_version/s" "$DEFAULT_NIX"
  fi

  # Fetch new tarball hash
  local url="https://registry.npmjs.org/${npm_name}/-/${pname}-${latest_version}.tgz"
  echo "  Fetching new hash for $url..."
  local new_hash
  new_hash=$(nix-prefetch-url --unpack "$url")

  perl -0777 -pi -e "s/(pname = \"$pname\".*?version = \"$latest_version\".*?hash = \")sha256-[^\"]+/\$1$new_hash/s" "$DEFAULT_NIX"

  # Update npmDepsHash (impure mode)
  echo "  Calculating new npmDepsHash..."
  local deps_hash
  deps_hash=$(nix eval --impure --raw "(import $DEFAULT_NIX {}).$pname.npmDepsHash" 2>/dev/null || echo "")

  if [[ -n "$deps_hash" ]]; then
    perl -0777 -pi -e "s/(pname = \"$pname\".*?npmDepsHash = \")sha256-[^\"]+/\$1$deps_hash/s" "$DEFAULT_NIX"
  fi

  echo "  $npm_name updated!"
}

# Detect all packages
while read -r pname npm_name; do
  update_package "$pname" "$npm_name"
done < <(
  perl -0777 -ne 'while(/mkNpmPackage\s*\{(.*?)\};/gs){ my $b=$1; my ($pname)=$b=~/pname\s*=\s*"([^"]+)"/; my ($npm)=$b=~/npmName\s*=\s*"([^"]+)"/; $npm=$pname unless $npm; print "$pname\t$npm\n";}' "$DEFAULT_NIX"
)

echo "All packages updated!"

