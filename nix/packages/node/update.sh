#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

DEFAULT_NIX="default.nix"

# package-lock.json を再生成
regenerate_package_lock() {
  local pname="$1"
  local lock_file="$2"
  echo "  Regenerating package-lock.json for $pname..."
  tmp_dir=$(mktemp -d)
  trap 'rm -rf "$tmp_dir"' RETURN ERR

  pushd "$tmp_dir" >/dev/null
  npm pack "$pname" --pack-destination . >/dev/null 2>&1
  tar -xzf ./*.tgz --strip-components=1
  npm install --package-lock-only --ignore-scripts >/dev/null 2>&1 || true
  popd >/dev/null

  cp "$tmp_dir/package-lock.json" "$lock_file"
}

# default.nix から npm / npx / pnpm / CLI ツールを抽出
get_npm_packages() {
  perl -0777 -ne '
    while (/mkNpmPackage\s*\{(.*?)\};/gs) {
      my $block = $1;
      my ($pname) = $block =~ /pname\s*=\s*"([^"]+)"/;
      print "$pname\n";
    }
  ' "$DEFAULT_NIX"
}

# 個別更新処理
update_package() {
  local pname="$1"
  echo "=== Updating $pname ==="

  current_version=$(grep -A5 "pname = \"$pname\"" "$DEFAULT_NIX" | perl -ne 'print $1 if /version = "([^"]+)/' | head -1)
  latest_version=$(npm view "$pname" version 2>/dev/null || echo "$current_version")

  if [[ "$current_version" == "$latest_version" ]]; then
    echo "  Already at latest version: $current_version"
    return
  fi

  echo "  Updating version $current_version → $latest_version"

  # default.nix の version を置換
  perl -pi -e "s/(pname = \"$pname\".*?version = \")$current_version/\${1}$latest_version/s" "$DEFAULT_NIX"

  # ソース tgz の hash を取得
  url="https://registry.npmjs.org/${pname}/-/${pname}-${latest_version}.tgz"
  echo "  Fetching hash..."
  new_hash=$(nix-prefetch-url --unpack "$url" | tail -1)
  new_sri=$(nix hash convert --hash-algo sha256 --to sri "$new_hash")

  # default.nix の hash を更新
  perl -0777 -pi -e "s/(pname = \"$pname\".*?hash = \")sha256-[^\"]+/\${1}$new_sri/s" "$DEFAULT_NIX"

  # package-lock.json があれば再生成
  lock_file="$pname/package-lock.json"
  [[ -f "$lock_file" ]] && regenerate_package_lock "$pname" "$lock_file"

  # npmDepsHash 計算
  echo "  Calculating npmDepsHash..."
  new_deps_hash=$(nix build --impure --expr "((import <nixpkgs> {}).callPackage ./. {}).\"$pname\"" 2>&1 | perl -ne 'print $1 if /got:\s+(\S+)/' || true)

  [[ -n "$new_deps_hash" ]] && \
    perl -0777 -pi -e "s/(pname = \"$pname\".*?npmDepsHash = \")sha256-[^\"]+/\${1}$new_deps_hash/s" "$DEFAULT_NIX"

  echo "  $pname updated to $latest_version"
}

# Node.js はスキップして npm / npx / pnpm / CLI ツールのみ更新
for pkg in $(get_npm_packages); do
  [[ "$pkg" == "nodejs" ]] && continue
  update_package "$pkg"
done

echo ""
echo "All packages updated!"

