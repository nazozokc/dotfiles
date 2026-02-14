#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
DEFAULT_NIX="default.nix"

# -----------------------------
# package-lock.json を再生成
# -----------------------------
regenerate_package_lock() {
  local npm_name="$1"
  local lock_file="$2"

  if [[ ! -f "$lock_file" ]]; then
    echo "  No package-lock.json for $npm_name, skipping"
    return
  fi

  echo "  Regenerating package-lock.json for $npm_name"
  local tmp_dir
  tmp_dir=$(mktemp -d)
  trap 'rm -rf "$tmp_dir"' RETURN ERR

  pushd "$tmp_dir" >/dev/null
  npm pack "$npm_name" --pack-destination . >/dev/null 2>&1 || echo "  Warning: npm pack failed"
  tar -xzf ./*.tgz --strip-components=1 >/dev/null 2>&1 || echo "  Warning: tar failed"
  npm install --package-lock-only --ignore-scripts >/dev/null 2>&1 || echo "  Warning: npm install failed"
  popd >/dev/null

  cp "$tmp_dir/package-lock.json" "$lock_file"
}

# -----------------------------
# default.nix から npm パッケージ一覧取得
# -----------------------------
get_npm_packages() {
  perl -0777 -ne '
    while (/mkNpmPackage\s*\{(.*?)\};/gs) {
      my $block = $1;
      my ($pname) = $block =~ /pname\s*=\s*"([^"]+)"/;
      next unless $pname;
      print "$pname\n";
    }
  ' "$DEFAULT_NIX"
}

# -----------------------------
# 個別 npm パッケージ更新
# -----------------------------
update_npm_package() {
  local pname="$1"
  echo "=== Updating $pname ==="

  # npx は npm と同期
  if [[ "$pname" == "npx" ]]; then
    echo "  npx version tied to npm, skipping individual update"
    return
  fi

  # 現在の version を取得
  local current_version
  current_version=$(perl -0777 -ne '
    while (/mkNpmPackage\s*\{(.*?)\};/gs) {
      my $b=$1;
      print $1 if $b =~ /pname\s*=\s*"'$pname'"/ && $b =~ /version\s*=\s*"([^"]+)"/;
    }
  ' "$DEFAULT_NIX")

  if [[ -z "$current_version" ]]; then
    echo "  Could not find current version for $pname"
    return
  fi

  # 最新バージョン取得
  local latest_version
  latest_version=$(npm view "$pname" version 2>/dev/null || echo "")
  if [[ -z "$latest_version" ]]; then
    echo "  Could not fetch latest version for $pname"
    return
  fi

  if [[ "$current_version" == "$latest_version" ]]; then
    echo "  Already at latest version: $current_version"
    return
  fi

  echo "  Updating $current_version → $latest_version"

  # default.nix 内のバージョン更新
  perl -0777 -pi -e "s/(mkNpmPackage\s*\{.*?pname\s*=\s*\"$pname\".*?version\s*=\s*\")[^\"]+/\$1$latest_version/s" "$DEFAULT_NIX"

  # source hash 更新
  local url="https://registry.npmjs.org/${pname}/-/${pname}-${latest_version}.tgz"
  echo "  Fetching new hash for $url"
  local new_hash
  new_hash=$(nix-prefetch-url --unpack "$url" 2>/dev/null)
  local new_sri
  new_sri=$(nix hash convert --hash-algo sha256 --to sri "$new_hash")

  perl -0777 -pi -e "s/(mkNpmPackage\s*\{.*?pname\s*=\s*\"$pname\".*?hash\s*=\s*\")[^\"]+/\$1$new_sri/s" "$DEFAULT_NIX"

  # package-lock.json 更新
  local lock_file="$pname/package-lock.json"
  regenerate_package_lock "$pname" "$lock_file"

  # npmDepsHash 更新
  echo "  Calculating npmDepsHash..."
  local new_deps_hash
  new_deps_hash=$(nix build --impure --expr "((import <nixpkgs> {}).callPackage ./. {}).\"$pname\"" 2>&1 | perl -ne 'print $1 if /got:\s+(\S+)/' || echo "")

  if [[ -n "$new_deps_hash" ]]; then
    perl -0777 -pi -e "s/(mkNpmPackage\s*\{.*?pname\s*=\s*\"$pname\".*?npmDepsHash\s*=\s*\")[^\"]+/\$1$new_deps_hash/s" "$DEFAULT_NIX"
  fi

  echo "  $pname updated to $latest_version"
}

# -----------------------------
# メイン処理
# -----------------------------
echo "Updating npm packages..."
for pkg in $(get_npm_packages); do
  update_npm_package "$pkg"
done

echo ""
echo "All npm packages updated safely!"

