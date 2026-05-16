#!/usr/bin/env bash
# gh-pr.sh - Create and view GitHub PR
# Usage: ./gh-pr.sh [base-branch] [--web]

set -euo pipefail

BASE_BRANCH="${1:-main}"
WEB_FLAG=""

if [[ ${2:-} == "--web" ]]; then
  WEB_FLAG="--web"
fi

echo "Creating PR to $BASE_BRANCH..."
gh pr create --base "$BASE_BRANCH" --fill $WEB_FLAG

echo ""
echo "PR created. Opening..."
gh pr view --web
