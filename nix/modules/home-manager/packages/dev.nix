{ pkgs }:

with pkgs;
[
  #general
  prettier

  # python
  python312
  pipx

  # JS,TS
  nodejs
  typescript-language-server
  typescript-go
  typescript
  pnpm
  bun
  deno
  yarn
  clang
  clang-tools

  # rust
  rustc
  rust-analyzer

  # nix
  nil
  nixd
  pkgs.nixfmt

  # Go-lang
  go
  go-tools

  # lua
  stylua

  #Java
  jdk

  #yaml
  yamlfmt

  # package tools
  cargo
  cmake
  ninja

]
++ lib.optionals pkgs.stdenv.isLinux [
  # front end tools
  vite
]
