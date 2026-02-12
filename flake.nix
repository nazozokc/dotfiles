{
  description = "nazozo dotfiles (home-manager first)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 将来用（mac買ったら使う）
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... }@inputs:
  let
    username = "nazozokc";

    ########################################
    # システム定義
    ########################################
    systems = {
      linux = "x86_64-linux";
      darwin = "aarch64-darwin";
    };

    ########################################
    # system ごとの pkgs
    ########################################
    pkgsFor = system: import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    ########################################
    # myPkgs 作成関数
    ########################################
    mkMyPkgs = system:
    let
      pkgs = pkgsFor system;

      cli  = import ./nix/home-manager/cli/default.nix { inherit pkgs; };
      gui  = import ./nix/home-manager/gui/default.nix { inherit pkgs; };
      lang = import ./nix/home-manager/lang/default.nix { inherit pkgs; };
    in
    {
      pkgs = pkgs;
      cli = cli;
      gui = gui;
      lang = lang;
      tools = [];
    };

  in
  {
    ########################################
    # Home Manager (Linux)
    ########################################
    homeConfigurations.${username} =
      home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor systems.linux;

        extraSpecialArgs = {
          inherit username inputs;
          myPkgs = mkMyPkgs systems.linux;
        };

        modules = [
          ./nix/shared.nix
          ./nix/home-manager/common.nix
          ./nix/home-manager/linux.nix
        ];
      };

    ########################################
    # nix-darwin (macOS)
    ########################################
    darwinConfigurations.${username} =
      darwin.lib.darwinSystem {
        system = systems.darwin;

        specialArgs = {
          inherit username inputs;
          myPkgs = mkMyPkgs systems.darwin;
        };

        modules = [
          ./nix/os/darwin.nix
        ];
      };
  };
}

