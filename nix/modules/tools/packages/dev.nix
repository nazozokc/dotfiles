{ pkgs }:

with pkgs;
[
  # Languages
  python312
  nodejs_24
  bun
  hono
  deno
  rustc

  # LSP / Formatter
  rust-analyzer
  nil
  nixd
  pkgs.nixfmt
  stylua

  # package tools
  cargo
  cmake
  ninja
]
