{
  description = "nazozo dotfiles (full multi-system with scripts)";

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

    pkgsFor = system: import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    linuxHome = "/home/${username}";
    darwinHome = "/Users/${username}";
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

        # パッケージまとめ
        home.packages = import ./nix/home-manager/common.nix { pkgs = pkgsFor "x86_64-linux"; };

        # symlink 作成
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

        # パッケージまとめ
        packages = import ./nix/home-manager/common.nix { pkgs = pkgsFor "aarch64-darwin"; };

        # symlink 作成
        activation = import ./nix/home-manager/symlinks.nix { inherit pkgs username; };
      };

    ########################################
    # Apps / スクリプト
    ########################################
    apps = {
      "x86_64-linux" = {
        switch = {
          type = "app";
          program = ''
            nix run nixpkgs#home-manager -- switch --flake .#${username}
          '';
        };
        update-node-packages = {
          type = "app";
          program = ''
            DOTFILES_DIR="${linuxHome}/ghq/github.com/nazozokc/dotfiles"
            bash "$DOTFILES_DIR/nix/packages/node/update.sh"
          '';
        };
        update-flake = {
          type = "app";
          program = ''
            nix flake update
          '';
        };
      };

      "aarch64-darwin" = {
        switch = {
          type = "app";
          program = ''
            nix run nixpkgs#nix-darwin -- switch --flake .#${username}
          '';
        };
        update-node-packages = {
          type = "app";
          program = ''
            DOTFILES_DIR="${darwinHome}/ghq/github.com/nazozokc/dotfiles"
            bash "$DOTFILES_DIR/nix/packages/node/update.sh"
          '';
        };
        update-flake = {
          type = "app";
          program = ''
            nix flake update
          '';
        };
      };
    };
  };
}

