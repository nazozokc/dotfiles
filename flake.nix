{
  description = "nazozo dotfiles (full multi-system with apps)";

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

    # ホームディレクトリをシステムごとに返す関数
    homeDirFor = system:
      if builtins.match ".*-darwin" system != null
      then "/Users/${username}"
      else "/home/${username}";
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

        # パッケージと symlink
        home.packages = import ./nix/home-manager/common.nix { pkgs = pkgsFor "x86_64-linux"; };
        home.activation = import ./nix/home-manager/symlinks.nix { pkgs = pkgsFor "x86_64-linux"; username = username; };
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

        # パッケージと symlink
        packages = import ./nix/home-manager/common.nix { pkgs = pkgsFor "aarch64-darwin"; };
        activation = import ./nix/home-manager/symlinks.nix { pkgs = pkgsFor "aarch64-darwin"; username = username; };
      };

    ########################################
    # apps (per-system)
    ########################################
    apps = let
      systems = [ "x86_64-linux" "aarch64-darwin" ];
    in builtins.listToAttrs (map (system: {
      name = system;
      value = let
        runPkgs = pkgsFor system;
        homedir = homeDirFor system;
      in
      {
        switch = {
          type = "app";
          program = runPkgs.writeShellScript "switch" ''
            set -eo pipefail
            echo "Switching configuration for ${system}..."
            if [ "$(uname)" = "Darwin" ]; then
              sudo nix run nix-darwin -- switch --flake .#${username}
            else
              nix run nixpkgs#home-manager -- switch --flake .#${username}
            fi
            echo "Done!"
          '';
        };

        update = {
          type = "app";
          program = runPkgs.writeShellScript "flake-update" ''
            set -e
            echo "Updating flake.lock..."
            nix flake update
            echo "Done! Run 'nix run .#${system}.switch' to apply changes."
          '';
        };

        update-node-packages = {
          type = "app";
          program = runPkgs.writeShellScript "update-node-packages" ''
            set -e
            echo "Updating Node.js packages..."
            DOTFILES_DIR="${homedir}/ghq/github.com/nazozokc/dotfiles"
            if [ ! -d "$DOTFILES_DIR" ]; then
              DOTFILES_DIR="$(pwd)"
            fi
            ${runPkgs.bash}/bin/bash "$DOTFILES_DIR/nix/packages/node/update.sh" "$@"
            echo "Node packages updated!"
          '';
        };
      };
    }) systems);
  };
}

