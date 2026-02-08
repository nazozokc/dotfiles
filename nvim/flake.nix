{
  description = "Neovim LSP devShell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          # Node / Web
          nodejs_20
          nodePackages.typescript
          nodePackages.typescript-language-server
          nodePackages.eslint
          vscode-langservers-extracted

          # Lua
          lua-language-server

          # Ruby
          solargraph

          # Rust
          rust-analyzer
          rustc
          cargo

          # C / C++
          clang
          clang-tools

          # Java
          jdk21
          jdt-language-server
        ];
      };
    };
}

