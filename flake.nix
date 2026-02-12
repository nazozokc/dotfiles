{
  description = "nazozo dotfiles (home-manager + nix-darwin, unified apps)";

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

        packages = import ./nix/home-manager/common.nix { pkgs = pkgsFor "aarch64-darwin"; };
        activation = import ./nix/home-manager/symlinks.nix { inherit pkgs username; };
      };

    ########################################
    # apps スクリプト（Linux / macOS 両対応）
    ########################################
    apps = let
      getHomeDir = ''
        if [[ "$(uname)" == "Darwin" ]]; then
          echo "/Users/${username}"
        else
          echo "/home/${username}"
        fi
      '';
    in
    {
      # Home Manager / nix-darwin 設定を切り替える
      switch = {
        type = "app";
        program = ''
          set -e
          if [[ "$(uname)" == "Darwin" ]]; then
            sudo nix run nix-darwin -- switch --flake .#${username}
          else
            nix run nixpkgs#home-manager -- switch --flake .#${username}
          fi
          echo "Switch complete!"
        '';
      };

      # flake.lock 更新
      update = {
        type = "app";
        program = ''
          set -e
          echo "Updating flake.lock..."
          nix flake update
          echo "Done! Run 'nix run .#switch' to apply."
        '';
      };

      # Node パッケージ更新
      update-node-packages = {
        type = "app";
        program = ''
          set -e
          HOME_DIR=$(${getHomeDir})
          echo "Updating Node packages in $HOME_DIR..."
          if [[ -f "$HOME_DIR/ghq/github.com/nazozokc/dotfiles/nix/packages/node/update.sh" ]]; then
            bash "$HOME_DIR/ghq/github.com/nazozokc/dotfiles/nix/packages/node/update.sh"
          else
            echo "Node update script not found at $HOME_DIR/ghq/github.com/nazozokc/dotfiles/nix/packages/node/update.sh"
            exit 1
          fi
          echo "Node packages update complete!"
        '';
      };
    };
  };
}

