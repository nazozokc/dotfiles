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

    systems = [
      "x86_64-linux"
      "aarch64-darwin"
    ];

    # pkgs を一元生成（後で overlay 足す場所）
    mkPkgs = system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

    # Home Manager 共通生成関数
    mkHome = system:
      home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs system;

        extraSpecialArgs = {
          inherit inputs username system;
        };

        modules = [
          ./nix/modules/home-manager/shared.nix

          # OS別
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
    # nix-darwin（macOS システム設定）
    ########################################
    darwinConfigurations = {
      "${username}" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";

        modules = [
          ./nix/modules/darwin/system.nix

          # Home Manager を nix-darwin に統合
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

