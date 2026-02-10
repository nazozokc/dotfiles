{
  description = "nazozo dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    homeConfigurations.nazozokc =
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ({ config, pkgs, ... }: {

            home.username = "nazozokc";
            home.homeDirectory = "/home/nazozokc";
            home.stateVersion = "24.05";

            programs.home-manager.enable = true;

          imports = [
          ./nix/home-files.nix
          ./nix/pkgs/cli-tool.nix
          ./nix/pkgs/nvim.nix
          ./nix/pkgs/gui-tool.nix  # ← 追加
          ];
          })
        ];
      };
  };
}

