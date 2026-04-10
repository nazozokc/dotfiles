{ pkgs }:

with pkgs;
[
  #agent
  ollama
  opencode
  claude-monitor
  claude-code
  qwen-code

  #other
  pay-respects

  #nix
  nix-output-monitor

  #downloader
  aria2
  mise
]
