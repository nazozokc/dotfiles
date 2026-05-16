#!/usr/bin/env bash
# cleanup-nix.sh - Clean up old Nix generations and store paths
# Usage: ./cleanup-nix.sh [--dry-run]

set -euo pipefail

DRY_RUN=""
if [[ ${1:-} == "--dry-run" ]]; then
  DRY_RUN="--dry-run"
  echo "DRY RUN MODE - no changes will be made"
  echo ""
fi

echo "========================================="
echo "  Nix Cleanup"
echo "========================================="
echo ""

# Show current generations
echo "Current generations:"
echo "-----------------------------------------"
nix-env --list-generations 2>/dev/null | tail -5 || echo "(unable to list generations)"
echo ""

# Show store size
echo "Current store size:"
du -sh /nix/store 2>/dev/null || echo "(unable to calculate)"
echo ""

# Delete old generations
echo "Deleting old generations..."
if command -v home-manager &>/dev/null; then
  home-manager expire-generations "-7 days" $DRY_RUN 2>/dev/null || true
fi

# Garbage collect
echo "Running garbage collector..."
nix-collect-garbage $DRY_RUN -d

echo ""

# Show new store size
echo "New store size:"
du -sh /nix/store 2>/dev/null || echo "(unable to calculate)"

echo ""
echo "========================================="
echo "  Cleanup complete!"
echo "========================================="
