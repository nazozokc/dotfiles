{
  description = "nazozo dotfiles (home-manager + nix-darwin unified)";

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
        home.activation = import ./nix/home-manager/symlinks.nix {
          pkgs = pkgsFor "x86_64-linux";
          username = username;
        };
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

        activation = import ./nix/home-manager/symlinks.nix {
          pkgs = pkgsFor "aarch64-darwin";
          username = username;
        };
      };

    ########################################
    # apps にスクリプトを統一フォーマットで追加
    ########################################
    apps = {
      # Linux 用
      "x86_64-linux" = {
        switch = {
          type = "app";
          program = ''
            echo "Building and switching Linux Home Manager config..."
            nix run nixpkgs#home-manager -- switch --flake .#${username}
            echo "Done!"
          '';
        };

        update-node-packages = {
          type = "app";
          program = ''
            echo "Updating Node packages..."
            ${pkgsFor "x86_64-linux"}/bin/bash ./nix/packages/node/update.sh
            echo "Done!"
          '';
        };
      };

      # macOS 用
      "aarch64-darwin" = {
        switch = {
          type = "app";
          program = ''
            echo "Building and switching macOS nix-darwin config..."
            sudo nix run nix-darwin -- switch --flake .#${username}
            echo "Done!"
          '';
        };

        update-node-packages = {
          type = "app";
          program = ''
            echo "Updating Node packages on macOS..."
            ${pkgsFor "aarch64-darwin"}/bin/bash ./nix/packages/node/update.sh
            echo "Done!"
          '';
        };
      };
    };
  };
}

