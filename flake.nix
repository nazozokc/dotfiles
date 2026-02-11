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

  outputs = { self, nixpkgs, home-manager, darwin, ... }:
  let
    username = "nazozokc";

    systems = {
      linux = "x86_64-linux";
      darwin = "aarch64-darwin";
    };
  in
  {
    ########################################
    # Linux (Home Manager)
    ########################################
    homeConfigurations."${username}-linux" =
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${systems.linux};

        modules = [
          ./nix/modules/shared.nix
          ./nix/modules/os/linux.nix
        ];

        extraSpecialArgs = {
          inherit username;
          systemType = "linux";
        };
      };

    ########################################
    # macOS (Home Manager only)
    ########################################
    homeConfigurations."${username}-darwin" =
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${systems.darwin};

        modules = [
          ./nix/modules/shared.nix
          ./nix/modules/os/darwin.nix
        ];

        extraSpecialArgs = {
          inherit username;
          systemType = "darwin";
        };
      };

    ########################################
    # nix-darwin system
    ########################################
    darwinConfigurations."${username}" =
      darwin.lib.darwinSystem {
        system = systems.darwin;

        modules = [
          ({ pkgs, ... }: {
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
            users.users.${username}.home = "/Users/${username}";
          })

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.${username} = {
              imports = [
                ./nix/modules/shared.nix
                ./nix/modules/os/darwin.nix
              ];
            };
          }
        ];
      };
  };
}

