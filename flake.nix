{
  description = "nazozo multi-system dotfiles";

  ########################################
  # Inputs
  ########################################
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

  ########################################
  # Outputs
  ########################################
  outputs = { self, nixpkgs, home-manager, darwin, ... }@inputs:
  let
    username = "nazozokc";

    systems = [
      "x86_64-linux"
      "aarch64-darwin"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;

  in {

    ########################################
    # Home Manager（Linux / mac 共通）
    ########################################
    homeConfigurations = forAllSystems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit inputs username;
        };

        modules = [
          ./nix/shared.nix
          ./nix/home-manager/common.nix

          (if pkgs.stdenv.isDarwin
            then ./nix/home-manager/darwin.nix
            else ./nix/home-manager/linux.nix)
        ];
      }
    );

    ########################################
    # nix-darwin（macOS システム）
    ########################################
    darwinConfigurations.${username} = darwin.lib.darwinSystem {
      system = "aarch64-darwin";

      specialArgs = {
        inherit inputs username;
      };

      modules = [
        ./nix/os/darwin.nix
      ];
    };
  };
}

