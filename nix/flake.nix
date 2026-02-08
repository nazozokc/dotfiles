{
  description = "nazozokc apps + neovim LSP (no home-manager)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    packages.${system} = {
      apps = pkgs.buildEnv {
        name = "nazozokc-apps";
        paths = import ./packages.nix { inherit pkgs; };
      };

      lsp = pkgs.buildEnv {
        name = "nazozokc-lsp";
        paths = import ./lsp.nix { inherit pkgs; };
      };
    };
  };
}

