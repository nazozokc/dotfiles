{
  description = "nazozo dotfiles (home-manager simple)";

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
    username = "nazozokc";
  in
  {
    homeConfigurations.${username} =
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };

        extraSpecialArgs = {
          inherit username inputs;
        };

        modules = [
          ./nix/shared.nix
          ./nix/home-manager/common.nix
          ./nix/home-manager/linux.nix
        ];
      };

    darwinConfigurations.${username} =
      darwin.lib.darwinSystem {
        system = "aarch64-darwin";

        specialArgs = {
          inherit username inputs;
        };

        modules = [
          ./nix/os/darwin.nix
        ];
      };
  };
}

