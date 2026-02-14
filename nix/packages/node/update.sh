#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

DEFAULT_NIX="default.nix"

get_npm_packages() {
  perl -0777 -ne '
    while (/mkNpmPackage\s*\{(.*?)\};/gs) {
      my $block = $1;
      my ($pname) = $block =~ /pname\s*=\s*"([^"]+)"/;
      print "$pname\n";
    }
  ' "$DEFAULT_NIX"
}

update_npm_package() {
  local pname="$1"
  local current_version latest_version url new_hash

  current_version=$(grep -A3 "pname = \"$pname\"" "$DEFAULT_NIX" | perl -ne 'print $1 if /version = "([^"]+)/' | head -1)
  latest_version=$(npm view "$pname" version 2>/dev/null || echo "")
  [ "$current_version" == "$latest_version" ] && { echo "$pname is up-to-date"; return; }

  echo "Updating $pname from $current_version → $latest_version"
  perl -pi -e "s/(pname = \"$pname\".*?version = \")$current_version/\${1}$latest_version/s" "$DEFAULT_NIX"

  url="https://registry.npmjs.org/$pname/-/$pname-$latest_version.tgz"
  new_hash=$(nix-prefetch-url --unpack "$url")
  perl -0777 -pi -e "s/(pname = \"$pname\".*?version = \"$latest_version\".*?hash = \")sha256-[^\"]+/\${1}$new_hash/s" "$DEFAULT_NIX"
}

for pkg in $(get_npm_packages); do
  update_npm_package "$pkg"
done

echo "All npm packages updated."

