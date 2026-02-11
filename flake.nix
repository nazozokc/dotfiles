{
  description = "nazozo multi-system dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... }@inputs:
  let
    systems = [ "x86_64-linux" "aarch64-darwin" ];
    username = "nazozokc";

    # システムごとに pkgs を渡すヘルパー
    forAllSystems = f:
      nixpkgs.lib.genAttrs systems (system:
        f system (import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        })
      );
  in {

    ########################################
    # Home Manager (Linux / Mac 共通)
    ########################################
    homeConfigurations = forAllSystems (system: pkgs:
      home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        modules = [
          ./nix/modules/shared.nix
          ./nix/modules/pkgs/cli.nix
          ./nix/modules/pkgs/gui.nix
          (if pkgs.stdenv.isLinux
            then ./nix/modules/os/linux.nix
            else ./nix/modules/os/darwin.nix)
          ./nix/config-sym.nix
        ];
      }
    );

    ########################################
    # nix-darwin (Mac用)
    ########################################
    darwinConfigurations = {
      "${username}" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./nix/modules/shared.nix
        ];
      };
    };
  };
}

