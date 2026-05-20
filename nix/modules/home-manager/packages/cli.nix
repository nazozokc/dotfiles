{ pkgs }:

with pkgs;
[
  # agent
  ollama
  opencode
  claude-monitor
  claude-code
  qwen-code
  codex
  pi-coding-agent
  stack
  grok-cli

  # other
  pay-respects

  # nix
  nix-output-monitor

  # downloader
  aria2
  mise
]
