{
  description = "nazozokc personal packages (apps + neovim LSP)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = { allowUnfree = true; };
    };
  in
  {
    packages.${system}.apps =
      pkgs.buildEnv {
        name = "nazozokc-apps";
        paths = import ./packages.nix { inherit pkgs; };
      };

    packages.${system}.lsp =
      pkgs.buildEnv {
        name = "nazozokc-lsp";
        paths = import ./lsp.nix { inherit pkgs; };
      };

    # デフォルトで apps + lsp
    packages.${system}.default =
      pkgs.buildEnv {
        name = "nazozokc-default";
        paths = [
          self.packages.${system}.apps
          self.packages.${system}.lsp
        ];
      };
  };
}

