{
  description = "nazozo dotfiles (multi-system, apps + nom)";

  # ---------------------------------------------------------------------------
  # Binary cache の設定
  # nixConfig はリテラルセットである必要があるためここに直接書く
  # ---------------------------------------------------------------------------
  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org/"
      "https://cache.numtide.com" # ← これ
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" # ← これ
    ];
  };

  # ---------------------------------------------------------------------------
  # Flake inputs
  # ---------------------------------------------------------------------------
  inputs = {
    # Nix パッケージセット (unstable チャンネル)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # flake を複数モジュールに分割するためのフレームワーク
    flake-parts.url = "github:hercules-ci/flake-parts";

    # LLM エージェントツール群
    llm-agents.url = "github:numtide/llm-agents.nix";

    # ユーザー環境管理 (nixpkgs に追従)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # macOS システム設定管理
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # GitHub CLI 拡張: コントリビューショングラフ表示
    gh-graph = {
      url = "github:kawarimidoll/gh-graph";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # GitHub CLI 拡張: 日報生成
    gh-nippou = {
      url = "github:ryoppippi/gh-nippou";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # GitHub CLI 拡張: 自慢ツール (flake 非対応なので flake = false)
    gh-brag = {
      url = "github:jackchuka/gh-brag";
      flake = false;
    };

    # nix-index の DB をビルド済みで提供 (nix-index 自体のビルドをスキップ)
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Claude Code 用スキル管理フレームワーク
    agent-skills-nix = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # ---------------------------------------------------------------------------
  # Flake outputs
  # ---------------------------------------------------------------------------
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
      treefmt-nix,
      agent-skills-nix,
      ...
    }:
    let
      username = "nazozokc";

      # カスタム overlay (./nix/overlays/default.nix)
      overlay = import ./nix/overlays;

      # システム文字列から nixpkgs インスタンスを生成するヘルパー
      # overlay と unfree パッケージを一括で適用する
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

      # Linux 向け home-manager 設定を生成するヘルパー
      # x86_64 / aarch64 で共通のモジュール構成を使い回す
      mkLinuxHomeConfig =
        system:
        let
          pkgs = pkgsFor system;
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            nix-index-database.homeModules.nix-index
            ./nix/shared.nix
            (import ./nix/modules/home-manager/tools-read.nix { inherit pkgs; })
            ./nix/modules/linux/system.nix
            ./nix/modules/home-manager/symlinks.nix
            agent-skills-nix.homeManagerModules.default
            ./nix/modules/home-manager/agent-skills.nix
          ];
        };

    in
    flake-parts.lib.mkFlake { inherit inputs; } {

      imports = [
        ./nix/modules/home-manager/packages/treefmt.nix
      ];
      systems = [
        "x86_64-linux" # メイン PC (Arch Linux)
        "aarch64-linux" # ARM Linux (VPS など)
        "aarch64-darwin" # macOS (Apple Silicon)
      ];

      # -------------------------------------------------------------------
      # perSystem: systems に列挙した各システムで自動展開されるセクション
      # -------------------------------------------------------------------
      perSystem =
        { system, ... }:
        let
          pkgs = pkgsFor system;

          # システム判定
          isDarwin = builtins.match ".*-darwin" system != null;

          # nix run .#build で参照するビルドターゲット
          hmConfig =
            if isDarwin then
              "darwinConfigurations.${username}.system"
            else
              "homeConfigurations.${username}.activationPackage";

          # nix run .#switch で渡す --flake ターゲット
          flakeTarget =
            if isDarwin then
              ".#${username}"
            else
              ".#${username}${if system == "aarch64-linux" then "-aarch64" else ""}";

          # app 実行時に表示する人間向けのシステム名
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
            # nix run .#switch
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

            # nix run .#build
            build = {
              type = "app";
              program = "${pkgs.writeShellScriptBin "build" ''
                set -eo pipefail
                ${printInfo "build"}
                ${pkgs.nix-output-monitor}/bin/nom build .#${hmConfig}
              ''}/bin/build";
            };

            # nix run .#update
            update = {
              type = "app";
              program = "${pkgs.writeShellScriptBin "update" ''
                set -eo pipefail
                ${printInfo "update"}
                nix flake update |& ${pkgs.nix-output-monitor}/bin/nom
              ''}/bin/update";
            };
          };
        };

      # -------------------------------------------------------------------
      # flake: perSystem に乗らない静的な出力 (homeConfigurations など)
      # -------------------------------------------------------------------
      flake = {
        # Linux 向け home-manager 設定
        homeConfigurations = {
          ${username} = mkLinuxHomeConfig "x86_64-linux";
          "${username}-aarch64" = mkLinuxHomeConfig "aarch64-linux";
        };

        # macOS 向け nix-darwin 設定
        darwinConfigurations.${username} = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit username; };
          modules = [
            nix-index-database.darwinModules.nix-index
            ./nix/modules/darwin/system.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.users.${username} = {
                imports = [
                  ./nix/shared.nix
                  (import ./nix/modules/home-manager/tools-read.nix {
                    pkgs = pkgsFor "aarch64-darwin";
                  })
                  ./nix/modules/home-manager/darwin.nix
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
