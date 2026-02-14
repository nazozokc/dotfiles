#!/usr/bin/env bash
set -euo pipefail

# update.sh: Node/NPM CLI packages hash and npmDepsHash auto updater
cd "$(dirname "$0")"
DEFAULT_NIX="default.nix"

# Regenerate package-lock.json
regenerate_package_lock() {
  local npm_name="$1"
  local lock_file="$2"

  echo "  Regenerating package-lock.json for $npm_name..."
  local tmp_dir
  tmp_dir=$(mktemp -d)
  trap 'rm -rf "$tmp_dir"' RETURN ERR

  pushd "$tmp_dir" >/dev/null
  npm pack "$npm_name" --pack-destination . >/dev/null 2>&1
  tar -xzf ./*.tgz --strip-components=1
  npm install --package-lock-only --ignore-scripts >/dev/null 2>&1 || true
  popd >/dev/null

  cp "$tmp_dir/package-lock.json" "$lock_file"
}

# Extract packages from default.nix
get_packages() {
  perl -0777 -ne '
    while (/mkNpmPackage\s*\{(.*?)\};/gs) {
      my $block = $1;
      my ($pname) = $block =~ /pname\s*=\s*"([^"]+)"/;
      my ($npm_name) = $block =~ /npmName\s*=\s*"([^"]+)"/;
      $npm_name //= $pname;
      print "$pname\t$npm_name\n";
    }
  ' "$DEFAULT_NIX"
}

update_package() {
  local pname="$1"
  local npm_name="$2"

  echo "Updating $npm_name..."
  local current_version
  current_version=$(perl -0777 -ne 'print $1 if /pname\s*=\s*"'$pname'".*?version\s*=\s*"([^"]+)"/s' "$DEFAULT_NIX")

  if [[ -z $current_version ]]; then
    echo "  Could not find version for $pname"
    return
  fi

  # 最新バージョン取得
  local latest_version
  latest_version=$(npm view "$npm_name" version 2>/dev/null || echo "")
  if [[ -z $latest_version ]]; then
    echo "  Could not fetch latest version"
    return
  fi

  if [[ "$current_version" == "$latest_version" ]]; then
    echo "  Already latest ($current_version)"
  else
    echo "  Updating version $current_version -> $latest_version"
    perl -0777 -pi -e 's/(pname\s*=\s*"'$pname'".*?version\s*=\s*")'"$current_version"'"/${1}'"$latest_version"'/' "$DEFAULT_NIX"
  fi

  # hash 更新
  local url="https://registry.npmjs.org/${npm_name}/-/${pname}-${latest_version}.tgz"
  echo "  Fetching new hash..."
  local new_hash
  new_hash=$(nix hash url --type sha256 "$url")
  perl -0777 -pi -e 's/(pname\s*=\s*"'$pname'".*?hash\s*=\s*")sha256-[^"]+/${1}'"$new_hash"'/' "$DEFAULT_NIX"

  # package-lock.json 更新
  local lock_file="./$pname/package-lock.json"
  [[ -d "$pname" ]] || mkdir -p "$pname"
  regenerate_package_lock "$npm_name" "$lock_file"

  # npmDepsHash 更新（正確な Nix hash）
  echo "  Calculating new npmDepsHash..."
  local new_deps_hash
  new_deps_hash=$(nix build --no-out-link ".#$pname" 2>&1 | perl -ne 'print $1 if /got:\s+(\S+)/' || true)
  if [[ -n $new_deps_hash ]]; then
    perl -0777 -pi -e 's/(pname\s*=\s*"'$pname'".*?npmDepsHash\s*=\s*")sha256-[^"]+/${1}'"$new_deps_hash"'/' "$DEFAULT_NIX"
  fi

  echo "  $npm_name updated!"
}

# 実行
while IFS=$'\t' read -r pname npm_name; do
  update_package "$pname" "$npm_name"
done < <(get_packages)

echo "All packages updated!"

