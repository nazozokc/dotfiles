{
  description = "nazozo dotfiles (multi-system, apps + nom)";

  ########################################
  # Minimal binary cache (official only)
  ########################################
  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org/"
    ];

    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix.url = "github:numtide/treefmt-nix";

    fish-na.url = "github:ryoppippi/fish-na";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ==================

    gh-graph = {
      url = "github:kawarimidoll/gh-graph";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gh-nippou = {
      url = "github:ryoppippi/gh-nippou";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      darwin,
      treefmt-nix,
      gh-nippou,
      gh-graph,
      fish-na,
      nix-index-database,
      ...
    }:
    let
      username = "nazozokc";

      overlay = import ./nix/overlays;

      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ overlay ];
        };

      linuxPkgs = pkgsFor "x86_64-linux";
      darwinPkgs = pkgsFor "aarch64-darwin";

      # treefmt 設定
      treefmtEval =
        system:
        treefmt-nix.lib.evalModule (pkgsFor system) {
          projectRootFile = "flake.nix";
          programs = {
            nixfmt.enable = true;
            deadnix.enable = true;
            statix.enable = true;
            prettier.enable = true;
          };
        };
    in
    {
      ########################################
      # Formatter
      ########################################
      formatter.x86_64-linux = (treefmtEval "x86_64-linux").config.build.wrapper;
      formatter.aarch64-darwin = (treefmtEval "aarch64-darwin").config.build.wrapper;

      ########################################
      # Linux Home Manager
      ########################################
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = linuxPkgs;
        extraSpecialArgs = {
          inherit username;
          inherit fish-na;
        };
        modules = [
          nix-index-database.hmModules.nix-index
          ./nix/shared.nix
          ./nix/modules/home-manager/tools-read.nix
          ./nix/modules/home-manager/linux.nix
          ./nix/modules/home-manager/symlinks.nix
        ];
      };

      ########################################
      # macOS nix-darwin
      ########################################
      darwinConfigurations.${username} = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit username;
          inherit fish-na;
        };
        modules = [
          {
            nixpkgs.overlays = [ overlay ];
            nixpkgs.config.allowUnfree = true;
          }

          nix-index-database.darwinModules.nix-index

          ./nix/modules/darwin/darwin.nix
          ./nix/modules/home-manager/tools-read.nix
          ./nix/modules/home-manager/symlinks.nix
        ];
      };

      ########################################
      # Apps
      ########################################
      apps = {
        "x86_64-linux" = {
          switch = {
            type = "app";
            program = "${linuxPkgs.writeShellScriptBin "hm-switch" ''
              set -e
              nix run nixpkgs#home-manager -- switch --flake .#${username} \
                |& ${linuxPkgs.nix-output-monitor}/bin/nom
            ''}/bin/hm-switch";
          };

          update = {
            type = "app";
            program = "${linuxPkgs.writeShellScriptBin "flake-update" ''
              nix flake update |& ${linuxPkgs.nix-output-monitor}/bin/nom
            ''}/bin/flake-update";
          };
        };

        "aarch64-darwin" = {
          switch = {
            type = "app";
            program = "${darwinPkgs.writeShellScriptBin "darwin-switch" ''
              sudo nix run nix-darwin -- switch --flake .#${username} \
                |& ${darwinPkgs.nix-output-monitor}/bin/nom
            ''}/bin/darwin-switch";
          };
        };
      };
    };
}
