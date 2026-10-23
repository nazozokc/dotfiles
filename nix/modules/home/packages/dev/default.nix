{ pkgs }:

let
  # 2026-10-21 Node.js セキュリティリリースの緊急ピン (fixed: 22.23.4 / 24.22.1 / 26.12.1)
  # CVE-2026-105482 (dns.resolve NUL truncation, high)
  # CVE-2026-105483 (TLS hostname bypass - fullwidth digits, high)
  # CVE-2026-106069 (TLS hostname bypass - IP, high)
  # CVE-2026-111497 (Brotli decoder OOB write RCE, high)
  # nixos-unstable チャネルが nodejs_26 >= 26.12.1 を配布したら
  # nodejsHotfixPkgs を削除して nodejs_latest に戻すこと。
  nodejsHotfixPkgs =
    (builtins.getFlake "github:NixOS/nixpkgs/1e4a58186c5274abbd1142e5dfb32bcb6569bff9")
    .legacyPackages.${pkgs.system};
in

with pkgs;
[
  # general
  prettier
  telescope

  # js,ts
  nodejsHotfixPkgs.nodejs_26
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
