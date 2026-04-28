{ pkgs }:

with pkgs;
[
  #agent
  ollama
  opencode
  claude-monitor
  claude-code
  qwen-code
  codex
  cmake
  gnumake
  gcc

  #other
  pay-respects

  #nix
  nix-output-monitor

  #downloader
  aria2
  mise
]
