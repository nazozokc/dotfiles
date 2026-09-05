#!/usr/bin/env bash
# wsl-setup.sh - Apply WSL system config (requires root)
#  1. Deploy wsl/wsl.conf to /etc/wsl.conf
#  2. Generate ja_JP.UTF-8 locale (Arch)
# Usage: sudo ~/.scripts/wsl-setup.sh

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Error: run with sudo (root required)" >&2
  exit 1
fi

# リポジトリルートを解決 (~/.scripts symlink 経由でも直パスでも対応)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(dirname "${SCRIPT_DIR}")"
WSL_CONF_SRC="${REPO_ROOT}/wsl/wsl.conf"

if [[ ! -f ${WSL_CONF_SRC} ]]; then
  echo "Error: ${WSL_CONF_SRC} not found" >&2
  exit 1
fi

echo "==> Deploying ${WSL_CONF_SRC} -> /etc/wsl.conf"
install -m 644 "${WSL_CONF_SRC}" /etc/wsl.conf
echo "    Done."

echo "==> Ensuring ja_JP.UTF-8 locale..."
if ! grep -qx 'ja_JP.UTF-8 UTF-8' /etc/locale.gen 2>/dev/null; then
  echo "ja_JP.UTF-8 UTF-8" >>/etc/locale.gen
  echo "    Added ja_JP.UTF-8 UTF-8 to /etc/locale.gen"
fi
locale-gen
echo "    Done."

echo ""
echo "==> Apply requires WSL restart. On Windows run:"
echo "    wsl --shutdown"
