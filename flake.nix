{
  description = "nazozo dotfiles (multi-system, apps + nom)";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org/"
      "https://numtide.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-filter.url = "github:numtide/nix-filter";
    llm-agents.url = "github:numtide/llm-agents.nix";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix.url = "github:numtide/treefmt-nix";

    gh-graph = {
      url = "github:kawarimidoll/gh-graph";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gh-nippou = {
      url = "github:ryoppippi/gh-nippou";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gh-brag = {
      url = "github:jackchuka/gh-brag";
      flake = false;
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      darwin,
      treefmt-nix,
      gh-graph,
      gh-nippou,
      gh-brag,
      flake-parts,
      nix-index-database,
      llm-agents,
      nix-filter,
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
          overlays = [
            (_final: _prev: { _llm-agents = llm-agents; })
            overlay
            gh-graph.overlays.default
            gh-nippou.overlays.default
          ];
        };

      linuxPkgs = pkgsFor "x86_64-linux";
      linuxAarch64Pkgs = pkgsFor "aarch64-linux";
      darwinPkgs = pkgsFor "aarch64-darwin";

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

      dotfilesDir-linux = "/home/${username}/ghq/github.com/nazozokc/dotfiles";
      dotfilesDir-darwin = "/Users/${username}/ghq/github.com/nazozokc/dotfiles";
    in
    {
      ########################################
      # Formatter
      ########################################
      formatter.x86_64-linux = (treefmtEval "x86_64-linux").config.build.wrapper;
      formatter.aarch64-linux = (treefmtEval "aarch64-linux").config.build.wrapper;
      formatter.aarch64-darwin = (treefmtEval "aarch64-darwin").config.build.wrapper;

      ########################################
      # Linux (x86)
      ########################################
      homeConfigurations.${username} =
        home-manager.lib.homeManagerConfiguration {
          pkgs = linuxPkgs;
          modules = [
            nix-index-database.homeModules.nix-index
            ./nix/shared.nix
            (import ./nix/modules/home-manager/tools-read.nix {
              pkgs = linuxPkgs;
              nodePackages = import ./nix/packages/node/default.nix {
                pkgs = linuxPkgs;
              };
            })
            ./nix/modules/home-manager/linux.nix
            ./nix/modules/home-manager/symlinks.nix
          ];
        };

      ########################################
      # Linux (ARM)
      ########################################
      homeConfigurations.${username}-aarch64 =
        home-manager.lib.homeManagerConfiguration {
          pkgs = linuxAarch64Pkgs;
          modules = [
            nix-index-database.homeModules.nix-index
            ./nix/shared.nix
            (import ./nix/modules/home-manager/tools-read.nix {
              pkgs = linuxAarch64Pkgs;
              nodePackages = import ./nix/packages/node/default.nix {
                pkgs = linuxAarch64Pkgs;
              };
            })
            ./nix/modules/home-manager/linux.nix
            ./nix/modules/home-manager/symlinks.nix
          ];
        };

      ########################################
      # macOS
      ########################################
      darwinConfigurations.${username} = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          nix-index-database.darwinModules.nix-index
          ./nix/modules/darwin/darwin.nix
          (import ./nix/modules/home-manager/tools-read.nix {
            pkgs = darwinPkgs;
            nodePackages = import ./nix/packages/node/default.nix {
              pkgs = darwinPkgs;
            };
          })
          ./nix/modules/home-manager/symlinks.nix
        ];
      };

      ########################################
      # Apps
      ########################################
      apps = {

        ########################################
        # x86 Linux
        ########################################
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
              set -e
              nix flake update \
                |& ${linuxPkgs.nix-output-monitor}/bin/nom
            ''}/bin/flake-update";
          };
        };

        ########################################
        # ARM Linux
        ########################################
        "aarch64-linux" = {

          switch = {
            type = "app";
            program = "${linuxAarch64Pkgs.writeShellScriptBin "hm-switch" ''
              set -e
              nix run nixpkgs#home-manager -- switch --flake .#${username}-aarch64 \
                |& ${linuxAarch64Pkgs.nix-output-monitor}/bin/nom
            ''}/bin/hm-switch";
          };

          update = {
            type = "app";
            program = "${linuxAarch64Pkgs.writeShellScriptBin "flake-update" ''
              set -e
              nix flake update \
                |& ${linuxAarch64Pkgs.nix-output-monitor}/bin/nom
            ''}/bin/flake-update";
          };
        };

        ########################################
        # macOS
        ########################################
        "aarch64-darwin" = {

          switch = {
            type = "app";
            program = "${darwinPkgs.writeShellScriptBin "darwin-switch" ''
              sudo nix run nix-darwin -- switch --flake .#${username} \
                |& ${darwinPkgs.nix-output-monitor}/bin/nom
            ''}/bin/darwin-switch";
          };

          update = {
            type = "app";
            program = "${darwinPkgs.writeShellScriptBin "flake-update" ''
              set -e
              nix flake update \
                |& ${darwinPkgs.nix-output-monitor}/bin/nom
            ''}/bin/flake-update";
          };
        };
      };
    };
}

