{ pkgs }:

with pkgs;
[
  # general
  prettier
  telescope

  # python
  python312
  pipx

  # js,ts
  nodejs_22
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

  # front end tools (Linux only)
]
++ lib.optionals stdenv.isLinux [
  vite
  chromium
]
