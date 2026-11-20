{ pkgs }:

with pkgs;
[
  ollama
  opencode
  claude-code
  codex
  claude-monitor
]

++ lib.optionals (stdenv.hostPlatform.system == "aarch64-darwin") [
  # codexbar は macOS のメニューバーアプリ (Intel Mac は nixpkgs 26.05 側に無い)
  codexbar
]
