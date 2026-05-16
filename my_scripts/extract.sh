#!/usr/bin/env bash
# extract.sh - Extract various archive files
# Usage: ./extract.sh <archive-file>

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: extract <archive-file>"
  echo ""
  echo "Supported formats:"
  echo "  .tar.bz2  .tar.gz  .tar.xz  .tar.zst"
  echo "  .tar      .tbz2    .tgz     .txz"
  echo "  .zip      .rar     .7z      .gz"
  echo "  .bz2      .xz      .zst     .lz"
  echo "  .lzma     .Z       .deb     .rpm"
  exit 1
fi

FILE="$1"

if [[ ! -f $FILE ]]; then
  echo "Error: File '$FILE' not found"
  exit 1
fi

echo "Extracting: $FILE"

case "$FILE" in
*.tar.bz2 | *.tbz2) tar xjf "$FILE" ;;
*.tar.gz | *.tgz) tar xzf "$FILE" ;;
*.tar.xz | *.txz) tar xJf "$FILE" ;;
*.tar.zst) tar --zstd -xf "$FILE" ;;
*.tar) tar xf "$FILE" ;;
*.bz2) bunzip2 "$FILE" ;;
*.gz) gunzip "$FILE" ;;
*.xz) unxz "$FILE" ;;
*.zst) unzstd "$FILE" ;;
*.lz) unlzip "$FILE" ;;
*.lzma) unlzma "$FILE" ;;
*.Z) uncompress "$FILE" ;;
*.zip) unzip "$FILE" ;;
*.rar) unrar x "$FILE" ;;
*.7z) 7z x "$FILE" ;;
*.deb)
  if command -v dpkg &>/dev/null; then
    dpkg-deb -x "$FILE" "${FILE%.deb}"
  else
    echo "Error: dpkg not found"
    exit 1
  fi
  ;;
*.rpm)
  if command -v rpm2cpio &>/dev/null; then
    rpm2cpio "$FILE" | cpio -idmv
  else
    echo "Error: rpm2cpio not found"
    exit 1
  fi
  ;;
*)
  echo "Error: Unknown archive format '$FILE'"
  exit 1
  ;;
esac

echo "Extraction complete."
