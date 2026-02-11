{
  description = "nazozo multi-system dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... }@inputs:
  let
    systems = [ "x86_64-linux" "aarch64-darwin" ];

    forAllSystems = f:
      nixpkgs.lib.genAttrs systems (system:
        f system (import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        })
      );

    username = "nazozokc";

  in {
    ########################################
    # Home Manager
    ########################################

    homeConfigurations = forAllSystems (system: pkgs:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = { inherit inputs username; };

        modules = [
          {
            home.username = username;
            home.homeDirectory =
              if pkgs.stdenv.isDarwin
              then "/Users/${username}"
              else "/home/${username}";

            home.stateVersion = "24.05";
          }

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
    # nix-darwin
    ########################################

    darwinConfigurations.${username} =
      darwin.lib.darwinSystem {
        system = "aarch64-darwin";

        modules = [
          ./nix/modules/shared.nix
        ];
      };
  };
}

