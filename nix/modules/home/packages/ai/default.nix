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

++ lib.optionals (openhands-agent-canvas != null) [
  # OpenHands Agent Canvas (llm-agents.nix 由来 / x86_64-darwin は未提供)
  openhands-agent-canvas
]
