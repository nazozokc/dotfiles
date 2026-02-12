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
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    ########################################
    # myPkgs 定義
    ########################################
    myPkgs = let
      cli = import ./nix/home-manager/pkgs/cli/default.nix { inherit pkgs; };
      gui = import ./nix/home-manager/pkgs/gui/default.nix { inherit pkgs; };
      lang = import ./nix/home-manager/pkgs/lang/default.nix { inherit pkgs; };
    in
    {
      pkgs = pkgs; # common.nix 内で with myPkgs.pkgs するため
      cli = cli;
      gui = gui;
      lang = lang;
      tools = []; # 必要なら追加
    };
  in
  {
    ########################################
    # Home Manager（Linux）
    ########################################
    homeConfigurations.${username} =
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit inputs username myPkgs;
        };

        modules = [
          ./nix/shared.nix
          ./nix/home-manager/common.nix
          ./nix/home-manager/linux.nix
        ];
      };

    ########################################
    # nix-darwin（macOS / まだ使わない）
    ########################################
    darwinConfigurations.${username} =
      darwin.lib.darwinSystem {
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

