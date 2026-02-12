{
  description = "nazozo dotfiles (my home-manager & nix-darwin)";

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

    # システムごとの pkgs を生成
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

        # パッケージまとめ
        home.packages = import ./nix/home-manager/common.nix { pkgs = pkgsFor "x86_64-linux"; };

        # symlink 作成
        home.activation = import ./nix/home-manager/symlinks.nix { 
          pkgs = pkgsFor "x86_64-linux"; 
          lib  = pkgsFor "x86_64-linux".lib;
          inherit username; 
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

        # パッケージまとめ
        packages = import ./nix/home-manager/common.nix { pkgs = pkgsFor "aarch64-darwin"; };

        # symlink 作成
        activation = import ./nix/home-manager/symlinks.nix { 
          pkgs = pkgsFor "aarch64-darwin"; 
          lib  = pkgsFor "aarch64-darwin".lib;
          inherit username; 
        };
      };
    
    ########################################
    # apps スクリプト化（Linux/macOS 両対応）
    ########################################
    apps = let
      linuxPkgs   = pkgsFor "x86_64-linux";
      darwinPkgs  = pkgsFor "aarch64-darwin";
    in
    {
      switch = {
        type = "app";
        program = ''
          if [ "$(uname)" = "Darwin" ]; then
            nix run nixpkgs#nix-darwin -- switch --flake .#${username}
          else
            nix run nixpkgs#home-manager -- switch --flake .#${username}
          fi
        '';
      };

      update-node-packages = {
        type = "app";
        program = ''
          echo "Updating Node.js packages..."
          if [ "$(uname)" = "Darwin" ]; then
            DOTFILES_DIR="/Users/${username}/ghq/github.com/nazozokc/dotfiles"
          else
            DOTFILES_DIR="/home/${username}/ghq/github.com/nazozokc/dotfiles"
          fi
          bash "$DOTFILES_DIR/nix/packages/node/update.sh"
        '';
      };

      update-flake = {
        type = "app";
        program = ''
          echo "Updating flake inputs..."
          nix flake update
        '';
      };
    };
  };
}

