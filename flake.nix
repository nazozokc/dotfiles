{
  description = "nazozo dotfiles (simple multi-system + packages + symlinks)";

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

        # ① パッケージまとめ
        home.packages = import ./nix/home-manager/common.nix { pkgs = pkgsFor "x86_64-linux"; };

        # ⑤ symlink 作成
        home.activation = import ./nix/home-manager/symlinks.nix { inherit pkgs username; };
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

        # ① パッケージまとめ
        packages = import ./nix/home-manager/common.nix { pkgs = pkgsFor "aarch64-darwin"; };

        # ⑤ symlink 作成
        activation = import ./nix/home-manager/symlinks.nix { inherit pkgs username; };
      };
  };
}

