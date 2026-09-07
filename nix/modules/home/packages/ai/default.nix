{ pkgs }:

with pkgs;
[
  ollama
  opencode
  codex
  claude-monitor
  claude-code
]

++ lib.optionals (stdenv.hostPlatform.system == "aarch64-darwin") [
  # codexbar: macOS (Apple Silicon) only
  codexbar
]
