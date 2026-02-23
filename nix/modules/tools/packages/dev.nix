{ pkgs }:

with pkgs;
[
  # python
  python312

  # JS,TS
  nodejs_24
  pnpm
  bun
  deno

  # C
  clang
  clang-tools

  # rust
  rustc
  rust-analyzer

  # nix
  nil
  nixd
  pkgs.nixfmt

  # lua
  stylua

  # package tools
  cargo
  cmake
  ninja
]
