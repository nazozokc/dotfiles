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

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    agent-skills-nix = {
      url = "github:Kyure-A/agent-skills-nix";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      home-manager,
      darwin,
      gh-graph,
      gh-nippou,
      gh-brag,
      nix-index-database,
      llm-agents,
      agent-skills-nix,
      ...
    }:
    let
      username = "nazozokc";
      overlay = import ./nix/overlays;

      pkgsFor =
        system:
        import nixpkgs {
          localSystem.system = system;
          config.allowUnfree = true;
          overlays = [
            (_: _: { _llm-agents = llm-agents; })
            overlay
            gh-graph.overlays.default
            gh-nippou.overlays.default
          ];
        };

      mkLinuxHomeConfig =
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor system;
          modules = [
            nix-index-database.homeModules.nix-index
            ./nix/shared.nix
            (import ./nix/modules/home-manager/tools-read.nix {
              pkgs = pkgsFor system;
            })
            ./nix/modules/home-manager/linux.nix
            ./nix/modules/home-manager/symlinks.nix
            agent-skills-nix.homeManagerModules.default
            ./nix/modules/home-manager/agent-skills.nix
          ];
        };

    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        { system, ... }:
        let
          pkgs = pkgsFor system;
          isDarwin = builtins.match ".*-darwin" system != null;
          hmConfig =
            if isDarwin then
              "darwinConfigurations.${username}.system"
            else
              "homeConfigurations.${username}.activationPackage";
          flakeTarget =
            if isDarwin then
              ".#${username}"
            else
              ".#${username}${if system == "aarch64-linux" then "-aarch64" else ""}";
          sysLabel =
            if system == "x86_64-linux" then
              "Linux (x86_64)"
            else if system == "aarch64-linux" then
              "Linux (aarch64)"
            else if system == "aarch64-darwin" then
              "macOS (Apple Silicon)"
            else
              system;
          printInfo = cmd: ''
            echo "  system : ${sysLabel}"
            echo "  target : ${flakeTarget}"
            echo "  cmd    : ${cmd}"
            echo ""
          '';
        in
        {
          apps = {
            switch = {
              type = "app";
              program = "${pkgs.writeShellScriptBin "switch" ''
                set -eo pipefail
                ${printInfo "switch"}
                ${
                  if isDarwin then
                    "sudo nix run nix-darwin -- switch --flake ${flakeTarget}"
                  else
                    "nix run nixpkgs#home-manager -- switch --flake ${flakeTarget}"
                } |& ${pkgs.nix-output-monitor}/bin/nom
              ''}/bin/switch";
            };

            build = {
              type = "app";
              program = "${pkgs.writeShellScriptBin "build" ''
                set -e
                ${printInfo "build"}
                ${pkgs.nix-output-monitor}/bin/nom build .#${hmConfig}
              ''}/bin/build";
            };

            update = {
              type = "app";
              program = "${pkgs.writeShellScriptBin "update" ''
                set -e
                ${printInfo "update"}
                nix flake update |& ${pkgs.nix-output-monitor}/bin/nom
              ''}/bin/update";
            };
          };
        };

      flake = {
        homeConfigurations = {
          ${username} = mkLinuxHomeConfig "x86_64-linux";
          "${username}-aarch64" = mkLinuxHomeConfig "aarch64-linux";
        };

        darwinConfigurations.${username} = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit username; };
          modules = [
            nix-index-database.darwinModules.nix-index
            ./nix/modules/darwin/darwin.nix
            ./nix/modules/darwin/system.nix

            home-manager.darwinModules.home-manager
            {
              home-manager.users.${username} = {
                imports = [
                  ./nix/shared.nix
                  (import ./nix/modules/home-manager/tools-read.nix {
                    pkgs = pkgsFor "aarch64-darwin";
                  })
                  ./nix/modules/home-manager/symlinks.nix
                  agent-skills-nix.homeManagerModules.default
                  ./nix/modules/home-manager/agent-skills.nix
                ];
              };
            }
          ];
        };
      };
    };
}
