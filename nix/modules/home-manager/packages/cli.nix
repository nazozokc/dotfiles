{ pkgs }:

with pkgs;
[
  #agent
  ollama
  opencode
  claude-code
  claude-monitor
  qwen-code

  #other
  pay-respects

  #nix
  nix-output-monitor

  #downloader
  aria2
  mise
]
