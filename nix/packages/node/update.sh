#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
DEFAULT_NIX="./default.nix"

update_package() {
  local pname="$1"
  local npm_name="$2"

  echo "Updating $npm_name..."

  local current_version latest_version
  current_version=$(perl -ne "print \$1 if /pname = \"$pname\".*?version = \"([^\"]+)\"/s" "$DEFAULT_NIX")
  latest_version=$(npm view "$npm_name" version 2>/dev/null)

  if [[ "$current_version" != "$latest_version" ]]; then
    echo "  Updating version $current_version -> $latest_version"
    perl -0777 -pi -e "s/(pname = \"$pname\".*?version = \")$current_version/\$1$latest_version/s" "$DEFAULT_NIX"
  else
    echo "  Already latest version: $current_version"
  fi

  local url="https://registry.npmjs.org/${npm_name}/-/${pname}-${latest_version}.tgz"
  echo "  Fetching new hash..."
  local new_hash
  new_hash=$(nix-prefetch-url --unpack "$url")
  perl -0777 -pi -e "s/(pname = \"$pname\".*?hash = \")sha256-[^\"]+/\$1$new_hash/s" "$DEFAULT_NIX"

  echo "  Calculating npmDepsHash..."
  local deps_hash
  deps_hash=$(nix build --impure --expr "((import ./default.nix {}).$pname)" --no-out-link | grep -oE 'sha256-[a-zA-Z0-9+/=]+' | head -1)
  if [[ -n "$deps_hash" ]]; then
    perl -0777 -pi -e "s/(pname = \"$pname\".*?npmDepsHash = \")sha256-[^\"]+/\$1$deps_hash/s" "$DEFAULT_NIX"
  fi

  echo "  $npm_name updated!"
}

while read -r pname npm_name; do
  update_package "$pname" "$npm_name"
done < <(
  perl -0777 -ne 'while(/mkNpmPackage\s*\{(.*?)\};/gs){ my $b=$1; my ($pname)=$b=~/pname\s*=\s*"([^"]+)"/; my ($npm)=$b=~/npmName\s*=\s*"([^"]+)"/; $npm=$pname unless $npm; print "$pname\t$npm\n";}' "$DEFAULT_NIX"
)

echo "All packages updated!"

