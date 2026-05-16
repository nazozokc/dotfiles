#!/usr/bin/env bash
# mkcd.sh - Create a directory and cd into it
# Usage: ./mkcd.sh <directory-name>

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: mkcd <directory-name>"
  exit 1
fi

DIR_NAME="$1"

# Create directory (with parents if needed)
mkdir -p "$DIR_NAME"

# cd into it
cd "$DIR_NAME"

echo "Created and entered: $(pwd)"
