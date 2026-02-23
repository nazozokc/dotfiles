{ pkgs }:

with pkgs;
[
  # Languages
  python312
  nodejs_24
  pnpm
  bun
  deno
  clang
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
