{
  description = "nazozo dotfiles (Linux/macOS unified)";

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

  outputs = { self, nixpkgs, home-manager, darwin, lib, ... }@inputs:
  let
    username = "nazozokc";

    # システムごとの pkgs
    pkgsFor = system: import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    # 共通モジュール呼び出し
    linuxPkgs = pkgsFor "x86_64-linux";
    darwinPkgs = pkgsFor "aarch64-darwin";

  in
  {
    ########################################
    # Linux 用 Home Manager
    ########################################
    homeConfigurations.${username} =
      home-manager.lib.homeManagerConfiguration {
        pkgs = linuxPkgs;

        extraSpecialArgs = { inherit username inputs; };

        modules = [
          ./nix/shared.nix
          ./nix/home-manager/common.nix
          ./nix/home-manager/linux.nix
        ];

        home.packages = import ./nix/home-manager/common.nix { pkgs = linuxPkgs; };
        home.activation = import ./nix/home-manager/symlinks.nix { pkgs = linuxPkgs; inherit username; };
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

        packages = import ./nix/home-manager/common.nix { pkgs = darwinPkgs; };
        activation = import ./nix/home-manager/symlinks.nix { pkgs = darwinPkgs; inherit username; };
      };

    ########################################
    # Apps / スクリプト化
    ########################################
    apps = lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (system: let
      pkgs = if system == "x86_64-linux" then linuxPkgs else darwinPkgs;
      homeDir = if system == "x86_64-linux" then "/home/${username}" else "/Users/${username}";
    in {
      switch = {
        type = "app";
        program = ''
          set -eo pipefail
          SYSTEM="$(uname)"
          echo "Switching configuration..."
          if [ "$SYSTEM" = "Darwin" ]; then
            sudo nix run nix-darwin -- switch --flake .#${username}
          else
            nix run nixpkgs#home-manager -- switch --flake .#${username}
          fi
          echo "Done!"
        '';
      };

      update = {
        type = "app";
        program = ''
          set -e
          echo "Updating flake.lock..."
          nix flake update
          echo "Done! Run 'nix run .#switch' to apply changes."
        '';
      };

      update-node-packages = {
        type = "app";
        program = ''
          set -e
          DOTFILES_DIR="${homeDir}/ghq/github.com/nazozokc/dotfiles"
          if [ ! -d "$DOTFILES_DIR" ]; then
            DOTFILES_DIR="$(pwd)"
          fi
          ${pkgs.bash}/bin/bash "$DOTFILES_DIR/nix/packages/node/update.sh" "$@"
          echo "Node packages updated!"
        '';
      };
    });
  };
}

