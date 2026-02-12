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

  outputs = inputs@{ self, nixpkgs, home-manager, darwin, ... }:
  let
    username = "nazozokc";

    mkPkgs = system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

    mkHome = system:
      home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs system;

        extraSpecialArgs = {
          inherit inputs username system;
        };

        modules = [
          ./nix/modules/home-manager/shared.nix

          (if system == "aarch64-darwin"
            then ./nix/modules/os/darwin.nix
            else ./nix/modules/os/linux.nix)
        ];
      };
  in
  {
    ########################################
    # Home Manager
    ########################################
    homeConfigurations = {
      "${username}" = mkHome "x86_64-linux";
      "${username}-darwin" = mkHome "aarch64-darwin";
    };

    ########################################
    # nix-darwin
    ########################################
    darwinConfigurations = {
      "${username}" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";

        modules = [
          ./nix/modules/darwin/system.nix

          home-manager.darwinModules.home-manager
          {
            home-manager.useUserPackages = true;
            home-manager.useGlobalPkgs = false;

            home-manager.users.${username} =
              import ./nix/modules/home-manager/shared.nix;
          }
        ];
      };
    };
  };
}

