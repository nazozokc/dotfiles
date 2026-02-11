{
  description = "nazozo dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
    url = "github:youwen5/zen-browser-flake";
    inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";

    # nixpkgs を allowUnfree 許可で読み込む
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;   # ← ここで unfree パッケージ許可
      };
    };
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
              ./nix/config-sym.nix
              ./nix/pkgs/cli/cli-tool.nix
              ./nix/pkgs/nvim.nix
              ./nix/pkgs/gui/gui-tool.nix
            ];
          })
        ];
      };
  };
}
