#!/usr/bin/env bash
# gh-new.sh - Create a new GitHub repo, clone it, and cd into it
# Usage: ./gh-new.sh <repo-name> [description]

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: gh-new <repo-name> [description]"
  echo "Example: gh-new my-project 'A cool project'"
  exit 1
fi

REPO_NAME="$1"
DESCRIPTION="${2:-}"

echo "Creating GitHub repository: $REPO_NAME"

# Create repo
if [[ -n $DESCRIPTION ]]; then
  gh repo create "$REPO_NAME" --public --description "$DESCRIPTION" --clone
else
  gh repo create "$REPO_NAME" --public --clone
fi

# cd into the repo
cd "$REPO_NAME"

echo ""
echo "Repository created and cloned."
echo "Current directory: $(pwd)"
