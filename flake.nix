{
  description = "nazozo dotfiles (simple multi-system)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 将来 mac で使うために nix-darwin
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... }@inputs:
  let
    username = "nazozokc";

    # システムごとの pkgs
    pkgsFor = system: import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    ########################################
    # Linux 用 Home Manager
    ########################################
    homeConfigurations.${username} =
      home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor "x86_64-linux";

        extraSpecialArgs = { inherit username inputs; };

        modules = [
          ./nix/shared.nix
          ./nix/home-manager/common.nix
          ./nix/home-manager/linux.nix
        ];
      };

    ########################################
    # macOS 用 nix-darwin
    ########################################
    darwinConfigurations.${username} =
      darwin.lib.darwinSystem {
        system = "aarch64-darwin";

        specialArgs = { inherit username inputs; };

        modules = [
          ./nix/os/darwin.nix
        ];
      };
  };
}

