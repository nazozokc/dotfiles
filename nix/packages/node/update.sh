#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
DEFAULT_NIX="default.nix"

regenerate_package_lock() {
  local pname="$1"
  local lock_file="$2"
  local tmp_dir
  tmp_dir=$(mktemp -d)
  trap 'rm -rf "$tmp_dir"' RETURN ERR

  echo "  Regenerating package-lock.json for $pname..."
  pushd "$tmp_dir" >/dev/null
  npm pack "$pname" --pack-destination . 2>/dev/null
  tar -xzf ./*.tgz --strip-components=1
  npm install --package-lock-only --ignore-scripts 2>/dev/null || true
  popd >/dev/null

  cp "$tmp_dir/package-lock.json" "$lock_file"
}

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
  local current_version latest_version new_hash new_sri new_deps_hash

  echo "Updating $pname..."

  current_version=$(grep -A5 "pname = \"$pname\"" "$DEFAULT_NIX" | perl -ne 'print $1 if /version = "([^"]+)"/' | head -1)
  if [[ -z $current_version ]]; then
    echo "  Could not find current version for $pname"
    return
  fi

  latest_version=$(npm view "$pname" version 2>/dev/null || echo "")
  if [[ -z $latest_version ]]; then
    echo "  Could not fetch latest version for $pname"
    return
  fi

  if [[ $current_version == "$latest_version" ]]; then
    echo "  Already at latest version: $current_version"
    return
  fi

  echo "  Updating from $current_version to $latest_version"
  perl -pi -e "BEGIN{\$found=0} if(/pname = \"$pname\"/){\$found=1} if(\$found && /version = \"$current_version\"/){\$_=~s/$current_version/$latest_version/; \$found=0}" "$DEFAULT_NIX"

  local url="https://registry.npmjs.org/$pname/-/$pname-$latest_version.tgz"
  new_hash=$(nix-prefetch-url --unpack "$url" 2>/dev/null | tail -1)
  new_sri=$(nix hash convert --hash-algo sha256 --to sri "$new_hash")
  perl -0777 -pi -e "s/(pname = \"$pname\".*?version = \"$latest_version\".*?hash = \")sha256-[^\"]+/\${1}$new_sri/s" "$DEFAULT_NIX"

  local lock_file="$pname/package-lock.json"
  mkdir -p "$pname"
  regenerate_package_lock "$pname" "$lock_file"

  new_deps_hash=$(nix hash file --type sha256 "$lock_file")
  perl -0777 -pi -e "s/(pname = \"$pname\".*?npmDepsHash = \")sha256-[^\"]+/\${1}$new_deps_hash/s" "$DEFAULT_NIX"

  echo "  Updated $pname to $latest_version"
  echo "    hash=$new_sri"
  echo "    npmDepsHash=$new_deps_hash"
}

echo "Updating npm packages..."
while read -r pname; do
  update_npm_package "$pname"
done < <(get_npm_packages)

echo "Update complete!"

