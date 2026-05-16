#!/usr/bin/env bash
# port-check.sh - Show listening ports and their processes
# Usage: ./port-check.sh [port-number]

set -euo pipefail

if [[ $# -ge 1 ]]; then
  PORT="$1"
  echo "Checking port: $PORT"
  echo "-----------------------------------------"

  if command -v ss &>/dev/null; then
    ss -tlnp "sport = :$PORT" 2>/dev/null || echo "No process listening on port $PORT"
  elif command -v lsof &>/dev/null; then
    lsof -i ":$PORT" -P -n 2>/dev/null || echo "No process listening on port $PORT"
  else
    echo "Error: Neither ss nor lsof found"
    exit 1
  fi
else
  echo "========================================="
  echo "  Listening Ports"
  echo "========================================="
  echo ""

  if command -v ss &>/dev/null; then
    ss -tlnp
  elif command -v lsof &>/dev/null; then
    lsof -i -P -n | grep LISTEN
  else
    echo "Error: Neither ss nor lsof found"
    exit 1
  fi
fi
