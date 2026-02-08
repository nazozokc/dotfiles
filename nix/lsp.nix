{ pkgs }:

with pkgs; [
  # Lua
  lua-language-server

  # JavaScript / TypeScript
  nodejs_20
  typescript
  typescript-language-server

  # HTML / CSS
  vscode-langservers-extracted

  # C / C++
  clang-tools

  # Rust
  rust-analyzer

  # Java
  jdk21
  jdt-language-server
]

