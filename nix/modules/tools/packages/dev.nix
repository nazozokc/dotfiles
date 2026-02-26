{ pkgs }:

with pkgs;
[
  # python
  python312

  # JS,TS
  nodejs
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

  #Java
  jdk

  # package tools
  cargo
  cmake
  ninja
]
