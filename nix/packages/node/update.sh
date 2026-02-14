#!/usr/bin/env bash
set -euo pipefail

# default.nix があるディレクトリに移動
cd "$(dirname "$0")"

DEFAULT_NIX="default.nix"

# npm パッケージ名と default.nix 内の pname を抽出
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
  local npmName="$2"

  echo "Updating $npmName..."

  # 現行バージョン取得
  current_version=$(perl -0777 -ne 'print $1 if /pname = "'"$pname"'".*?version = "([^"]+)"/s' "$DEFAULT_NIX")
  latest_version=$(npm view "$npmName" version 2>/dev/null || echo "")

  if [[ -z $latest_version ]]; then
    echo "  Could not fetch latest version for $npmName"
    return
  fi
  if [[ "$current_version" == "$latest_version" ]]; then
    echo "  Already at latest version ($current_version)"
    return
  fi

  echo "  Updating from $current_version → $latest_version"

  # default.nix 内の version を更新
  perl -0777 -pi -e 's/(pname = "'"$pname"'".*?version = ")'"$current_version"'"/${1}'"$latest_version"'/' "$DEFAULT_NIX"

  # 新しい tarball ハッシュを取得
  url="https://registry.npmjs.org/$npmName/-/$pname-$latest_version.tgz"
  new_hash=$(nix-prefetch-url --unpack "$url")

  # default.nix の hash を更新
  perl -0777 -pi -e 's/(pname = "'"$pname"'".*?hash = ")sha256-[^"]+/${1}'"$new_hash"'/' "$DEFAULT_NIX"

  echo "  Updated $pname to $latest_version"
}

echo "Updating npm packages from default.nix..."
while IFS=$'\t' read -r pname npmName; do
  update_npm_package "$pname" "$npmName"
done < <(get_npm_packages)

echo "All updates complete!"

