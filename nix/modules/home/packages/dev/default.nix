{ pkgs }:

with pkgs;
[
  # general
  prettier
  telescope

  # python
  python312

  # js,ts
  nodejs_latest
  typescript-language-server
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
  nixfmt

  # go
  go
  go-tools

  # lua
  stylua

  # java
  jdk

  # yaml
  yamlfmt

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
