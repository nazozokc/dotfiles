{ pkgs }:

with pkgs;
[
  # python
  python312

  # JS,TS
  nodejs
  typescript-language-server
  typescript-go
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
