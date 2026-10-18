{ pkgs }:

with pkgs;
[
  # general
  prettier
  telescope

  # js,ts
  nodejs_latest
  bun
  deno
  yarn
  pnpm

  # rust
  rustc
  # rustup は cargo と _cargo completion が衝突するため除外。
  rust-analyzer

  # nix
  nil
  nixd
  nixfmt

  # go
  go
  go-tools

  # lua
  stylua

  # java
  jdk

  #clang
  clang
  clang-tools

  # yaml
  yamlfmt
  efm-langserver

  # package tools
  cargo
  cmake
  ninja

  # playwright
  playwright-driver

  # sqlite
  sqlite

  # penetration-test
  aircrack-ng
  crunch
]
++ lib.optionals stdenv.isLinux [
  # front end tools (Linux only)
  vite
  chromium
]
