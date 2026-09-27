{ pkgs }:

with pkgs;
let
  typescript_5 = typescript_5_9;
in
[
  # general
  prettier
  telescope

  # python
  python312

  # js,ts
  nodejs_latest
  # tsserver のみを PATH に出す。
  # nvim の typescript-tools.nvim は PATH 上の tsserver から Nix store の
  # tsserver.js を解決する。pkgs.typescript は TS7 で tsserver を持たないため
  # TS5 を使う。tsc は shadow したく無いので bin/tsserver だけをリンクする。
  (runCommand "tsserver" { } ''
    mkdir -p "$out/bin"
    ln -s ${typescript_5}/bin/tsserver "$out/bin/tsserver"
  '')
  typescript-language-server
  bun
  deno
  yarn
  pnpm

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
