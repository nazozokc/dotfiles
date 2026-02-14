#!/usr/bin/env bash
set -euo pipefail

# ===============================
# Node/NPM package hash updater
# Updates version, hash, and npmDepsHash in default.nix
# ===============================

cd "$(dirname "$0")"
DEFAULT_NIX="default.nix"

# Helper: regenerate package-lock.json in temp dir
regenerate_package_lock() {
  local npm_name="$1"
  local lock_file="$2"

  echo "  Regenerating package-lock.json for $npm_name"
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

# Extract npm packages from default.nix
get_npm_packages() {
  perl -0777 -ne '
      while (/mkNpmPackage\s*\{(.*?)\};/gs) {
          my $block = $1;
          my ($pname) = $block =~ /pname\s*=\s*"([^"]+)"/;
          my ($npmName) = $block =~ /npmName\s*=\s*"([^"]+)"/;
          $npmName //= $pname;
          print "$pname\t$npmName\n";
      }
  ' "$DEFAULT_NIX"
}

update_npm_package() {
  local pname="$1"
  local npm_name="$2"

  echo "Updating $npm_name..."

  # 現在の version を取得
  local current_version
  current_version=$(perl -0777 -ne 'print $1 if /pname\s*=\s*"'$pname'".*?version\s*=\s*"([^"]+)"/s' "$DEFAULT_NIX")

  if [[ -z $current_version ]]; then
    echo "  Could not find current version for $pname"
    return
  fi

  # 最新 version を取得
  local latest_version
  latest_version=$(npm view "$npm_name" version 2>/dev/null || echo "")

  if [[ -z $latest_version ]]; then
    echo "  Could not fetch latest version for $npm_name"
    return
  fi

  if [[ $current_version == "$latest_version" ]]; then
    echo "  Already at latest version: $current_version"
  else
    echo "  Updating version $current_version → $latest_version"
    perl -0777 -pi -e 's/(pname\s*=\s*"'$pname'".*?version\s*=\s*)"'$current_version'"/${1}"'$latest_version'"/s' "$DEFAULT_NIX"
  fi

  # 新しいソース hash を取得
  local url="https://registry.npmjs.org/${npm_name}/-/${pname}-${latest_version}.tgz"
  echo "  Fetching new source hash..."
  local new_hash
  new_hash=$(nix-prefetch-url --unpack "$url" 2>/dev/null)
  local new_hash_sri="sha256-$new_hash"

  # default.nix の hash 行を更新
  perl -0777 -pi -e 's/(pname\s*=\s*"'$pname'".*?hash\s*=\s*")sha256-[^"]+(")/${1}'$new_hash_sri'${2}/s' "$DEFAULT_NIX"

  # package-lock.json を再生成
  local lock_file="$pname/package-lock.json"
  if [[ -f $lock_file ]]; then
    regenerate_package_lock "$npm_name" "$lock_file"
  fi

  # npmDepsHash を計算
  if [[ -f $lock_file ]]; then
    echo "  Calculating new npmDepsHash..."
    local deps_hash
    deps_hash=$(nix hash file --type sha256 "$lock_file")
    deps_hash="sha256-$deps_hash"
    perl -0777 -pi -e 's/(pname\s*=\s*"'$pname'".*?npmDepsHash\s*=\s*")sha256-[^"]+(")/${1}'$deps_hash'${2}/s' "$DEFAULT_NIX"
  fi

  echo "  $npm_name updated!"
}

# Main loop
echo "Updating npm packages from $DEFAULT_NIX..."
while IFS=$'\t' read -r pname npm_name; do
  update_npm_package "$pname" "$npm_name"
done < <(get_npm_packages)

echo ""
echo "All npm packages updated!"

