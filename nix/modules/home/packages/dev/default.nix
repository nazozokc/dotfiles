{ pkgs }:

with pkgs;
[
  # general
  prettier
  telescope

  # js,ts
  nodePackages_latest
  bun
  deno
  yarn
  pnpm

  # rust
  rustc
  rustup

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
