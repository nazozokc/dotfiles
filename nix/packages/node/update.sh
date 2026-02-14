#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
DEFAULT_NIX="default.nix"

echo "Updating npm packages in $DEFAULT_NIX..."

# default.nix から mkNpmPackage の pname と npmName を抽出
mapfile -t PKGS < <(
    perl -0777 -ne '
        while (/mkNpmPackage\s*\{(.*?)\};/gs) {
            my $block = $1;
            my ($pname) = $block =~ /pname\s*=\s*"([^"]+)"/;
            my ($npm_name) = $block =~ /npmName\s*=\s*"([^"]+)"/;
            $npm_name //= $pname;
            print "$pname\t$npm_name\n";
        }
    ' "$DEFAULT_NIX"
)

for pkg_pair in "${PKGS[@]}"; do
    pname="${pkg_pair%%$'\t'*}"
    npm_name="${pkg_pair##*$'\t'}"
    echo "Processing $npm_name..."

    # 現在のバージョン
    current_version=$(grep -A5 "pname = \"$pname\"" "$DEFAULT_NIX" | perl -ne 'print $1 if /version = "([^"]+)/' | head -1)
    [[ -z "$current_version" ]] && echo "  Could not find current version, skipping." && continue

    # 最新バージョンを取得
    latest_version=$(npm view "$npm_name" version 2>/dev/null || true)
    [[ -z "$latest_version" ]] && echo "  Could not fetch latest version, skipping." && continue
    [[ "$current_version" == "$latest_version" ]] && echo "  Already latest ($current_version)" && continue

    echo "  Updating $current_version -> $latest_version"

    # 新しい hash
    url="https://registry.npmjs.org/${npm_name}/-/${pname}-${latest_version}.tgz"
    new_hash=$(nix-prefetch-url --unpack "$url")
    new_sri=$(nix hash convert --hash-algo sha256 --to sri "$new_hash")

    # default.nix の version と hash を更新
    perl -0777 -pi -e "
        s/(pname *= *\"$pname\".*?version *= *\")$current_version(\")/$1$latest_version$2/s;
        s/(pname *= *\"$pname\".*?hash *= *\")[^\"]+/$1$new_sri/s;
    " "$DEFAULT_NIX"

    # npmDepsHash を更新（nix-build で計算）
    echo "  Calculating npmDepsHash..."
    new_deps_hash=$(nix build --impure --expr "((import <nixpkgs> {}).callPackage ./. {}).\"$npm_name\"" 2>&1 \
                    | perl -ne 'print $1 if /got:\s+(\S+)/' || true)
    if [[ -n "$new_deps_hash" ]]; then
        perl -0777 -pi -e "
            s/(pname *= *\"$pname\".*?npmDepsHash *= *\")[^\"]+/$1$new_deps_hash/s;
        " "$DEFAULT_NIX"
        echo "  npmDepsHash updated"
    else
        echo "  Could not calculate npmDepsHash, skipping"
    fi

    echo "  $npm_name updated"
done

echo "All updates done!"

