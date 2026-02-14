#!/usr/bin/env bash
set -euo pipefail

# -------------------------------
# update.sh for npm packages in default.nix
# Pure bash version, no node-env generation
# -------------------------------

DEFAULT_NIX="./default.nix"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Initializing npm packages from $DEFAULT_NIX..."

# --- Extract packages from default.nix ---
# Looks for mkNpmPackage { pname = "..." ... };
PKGS=($(awk '/pname *= *"/ {gsub(/[ ";]/,""); print $3}' "$DEFAULT_NIX"))

echo "Detected packages: ${PKGS[*]}"

for PKG in "${PKGS[@]}"; do
  echo "=== Processing $PKG ==="

  # Get current version from default.nix
  CURRENT_VERSION=$(awk -v pkg="$PKG" '
    $0 ~ "pname *= *\"" pkg "\"" {found=1}
    found && $0 ~ "version *= *\"" {gsub(/.*version *= *"/,""); gsub(/".*/,""); print; exit}
  ' "$DEFAULT_NIX")

  # Get latest version from npm
  LATEST_VERSION=$(npm view "$PKG" version 2>/dev/null || echo "")
  if [[ -z $LATEST_VERSION ]]; then
    echo "  Could not fetch latest version for $PKG, skipping."
    continue
  fi
  echo "  $CURRENT_VERSION -> $LATEST_VERSION"

  # Fetch new source hash
  URL="https://registry.npmjs.org/$PKG/-/$PKG-$LATEST_VERSION.tgz"
  HASH=$(nix-prefetch-url --unpack "$URL")
  echo "  Source hash: $HASH"

  # Compute npmDepsHash
  PKGDIR="$TMPDIR/$PKG"
  mkdir -p "$PKGDIR"
  pushd "$PKGDIR" >/dev/null
  npm init -y >/dev/null
  npm install "$PKG@$LATEST_VERSION" --package-lock-only >/dev/null
  NPMDEPSHASH=$(nix hash path ./node_modules --type sha256)
  popd >/dev/null
  echo "  npmDepsHash: $NPMDEPSHASH"

  # Update default.nix
  awk -v pkg="$PKG" -v ver="$LATEST_VERSION" -v hash="$HASH" -v deps="$NPMDEPSHASH" '
    BEGIN {inBlock=0}
    {
      if ($0 ~ "pname *= *\"" pkg "\"") inBlock=1
      if (inBlock && $0 ~ "version *= *") $0 = gensub(/version *= *".*"/, "version = \"" ver "\"", "g")
      if (inBlock && $0 ~ "hash *= *") $0 = gensub(/hash *= *".*"/, "hash = \"" hash "\"", "g")
      if (inBlock && $0 ~ "npmDepsHash *= *") $0 = gensub(/npmDepsHash *= *".*"/, "npmDepsHash = \"" deps "\"", "g")
      if (inBlock && $0 ~ "};") inBlock=0
      print
    }' "$DEFAULT_NIX" > "$DEFAULT_NIX.tmp"
  mv "$DEFAULT_NIX.tmp" "$DEFAULT_NIX"

  echo "  $PKG updated in $DEFAULT_NIX"
done

echo ""
echo "All packages updated in $DEFAULT_NIX!"

