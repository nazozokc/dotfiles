#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
DEFAULT_NIX="default.nix"

# -----------------------------
# default.nix から npm パッケージ一覧取得
# -----------------------------
get_npm_packages() {
  echo "npm"
  echo "npx"
  echo "pnpm"
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
      if($b =~ /pname\s*=\s*"'$pname'"/ && $b =~ /version\s*=\s*"([^"]+)"/) {
        print $1;
      }
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
  perl -0777 -pi -e "s/(mkNpmPackage\s*\{.*?pname\s*=\s*\"$pname\".*?version\s*=\s*\")\Q$current_version\E/\$1$latest_version/s" "$DEFAULT_NIX"

  # source hash 更新
  local url="https://registry.npmjs.org/${pname}/-/${pname}-${latest_version}.tgz"
  echo "  Fetching new hash for $url"
  local new_hash
  new_hash=$(nix-prefetch-url --unpack "$url" 2>/dev/null)
  local new_sri
  new_sri=$(nix hash convert --hash-algo sha256 --to sri "$new_hash")

  perl -0777 -pi -e "s/(mkNpmPackage\s*\{.*?pname\s*=\s*\"$pname\".*?hash\s*=\s*\")[^\"]+/\$1$new_sri/s" "$DEFAULT_NIX"

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
echo "npm / npx / pnpm update complete!"

