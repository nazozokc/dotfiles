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
      "cache.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" # ← これ
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

    # 秘密鍵管理
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # GPU ライブラリラッパー (非 NixOS で Nix GUI アプリを動かす)
    nixGL = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ---------------------------------------------------------------------------
    # x86_64-darwin (Intel Mac) 専用スタック
    # nixpkgs 26.11 で x86_64-darwin のサポートが削除されたため、
    # 最後に対応している nixpkgs 26.05 系を利用する (2026 年末まで保守)
    # ---------------------------------------------------------------------------
    nixpkgs-intel = {
      url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    };
    home-manager-intel = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-intel";
    };
    darwin-intel = {
      # nix-darwin は nixpkgs のリリースと対応するブランチを使う (26.05 系)
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-intel";
    };
    llm-agents-intel = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs-intel";
    };
    gh-graph-intel = {
      url = "github:kawarimidoll/gh-graph";
      inputs.nixpkgs.follows = "nixpkgs-intel";
    };
    gh-nippou-intel = {
      url = "github:ryoppippi/gh-nippou";
      inputs.nixpkgs.follows = "nixpkgs-intel";
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
      sops-nix,
      nixGL,
      # x86_64-darwin (Intel Mac) 専用スタック
      nixpkgs-intel,
      home-manager-intel,
      darwin-intel,
      llm-agents-intel,
      gh-graph-intel,
      gh-nippou-intel,
      ...
    }:
    let
      # username is defined in nix/shared.nix
      # This local definition is for flake-level references only
      username = "nazozokc";

      # カスタム overlay (./nix/overlays/default.nix)
      overlay = import ./nix/overlays;

      # nixpkgs インスタンス生成ヘルパー (nix/lib/pkgs.nix)
      # Intel Mac (x86_64-darwin) は 26.05 系スタックを使い分ける
      pkgsFor = import ./nix/lib/pkgs.nix {
        inherit
          nixpkgs
          nixpkgs-intel
          llm-agents
          llm-agents-intel
          gh-graph
          gh-graph-intel
          gh-nippou
          gh-nippou-intel
          overlay
          ;
      };

      # Linux 向け home-manager 設定生成 (nix/modules/linux/build.nix)
      mkLinuxHomeConfig = import ./nix/modules/linux/build.nix {
        inherit
          self
          username
          pkgsFor
          home-manager
          nix-index-database
          sops-nix
          agent-skills-nix
          nixGL
          ;
      };

      # WSL 向け home-manager 設定生成 (nix/modules/wsl/build.nix)
      mkWSLHomeConfig = import ./nix/modules/wsl/build.nix {
        inherit
          self
          username
          pkgsFor
          home-manager
          nix-index-database
          sops-nix
          agent-skills-nix
          ;
      };

      # macOS (nix-darwin) 向け設定生成 (nix/modules/macos/build.nix)
      # Apple Silicon/Intel で 26.11/26.05 系スタックを使い分ける
      mkDarwinConfig = import ./nix/modules/macos/build.nix {
        inherit
          self
          username
          pkgsFor
          nixpkgs
          darwin
          darwin-intel
          home-manager
          home-manager-intel
          sops-nix
          agent-skills-nix
          ;
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {

      imports = [
        ./nix/modules/home/packages/treefmt.nix
      ];
      systems = [
        "x86_64-linux" # メイン PC (Arch Linux)
        "aarch64-linux" # ARM Linux (VPS など)
        "aarch64-darwin" # macOS (Apple Silicon)
        "x86_64-darwin" # macOS (Intel Mac)
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

          # darwin 設定名 (Apple Silicon: 無印 / Intel: -x86_64 サフィックス)
          darwinConfigName = if system == "x86_64-darwin" then "${username}-x86_64" else username;

          # nix run .#build で参照するビルドターゲット
          hmConfig =
            if isDarwin then
              "darwinConfigurations.${darwinConfigName}.system"
            else
              "homeConfigurations.${username}.activationPackage";

          # nix run .#switch で渡す --flake ターゲット
          flakeTarget =
            if isDarwin then
              ".#${darwinConfigName}"
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
            else if system == "x86_64-darwin" then
              "macOS (Intel)"
            else
              system;

          printInfo = cmd: ''
            echo "  system : ${sysLabel}"
            echo "  target : ${flakeTarget}"
            echo "  cmd    : ${cmd}"
            echo ""
          '';

          # Shared shell helpers for runtime environment detection
          detectHelpers = ''
            is_wsl() {
              [ -d /run/WSL ] || grep -qi microsoft /proc/version 2>/dev/null
            }

            is_darwin() {
              [ "$(uname)" = "Darwin" ]
            }

            # Windows ユーザープロファイルの .wslconfig パスを検出
            # (USERPROFILE env が無い場合は /mnt/c/Users/ から実ユーザーをスキャン)
            find_wslconfig() {
              local profile
              profile="''${USERPROFILE%/}"
              if [[ -z "$profile" ]]; then
                for d in /mnt/c/Users/*/; do
                  case "$(basename "$d")" in
                    "All Users"|"Default"|"Default User"|"Public") continue ;;
                  esac
                  if [[ -e "$d/.wslconfig" || -d "$d/AppData" ]]; then
                    profile="''${d%/}"
                    break
                  fi
                done
              fi
              [[ -n "$profile" ]] && echo "$profile/.wslconfig"
            }

            # .wslconfig が apply.ps1 管理の symlink か事前チェック
            # (Windows側 %USERPROFILE%\.wslconfig を参照するため)
            check_wslconfig() {
              local wslconfig target
              wslconfig="$(find_wslconfig)"
              if [[ -z "$wslconfig" || ! -e "$wslconfig" ]]; then
                echo "[!] .wslconfig が見つかりません (''${wslconfig:-/mnt/c/Users/*/})"
                echo "    Windows 側で 'pwsh windows/apply.ps1' を実行して .wslconfig を symlink してください"
              elif [[ -L "$wslconfig" ]]; then
                target="$(readlink "$wslconfig")"
                case "$target" in
                  *"/wsl/.wslconfig"|*"\\wsl\\.wslconfig") echo "[ok] .wslconfig -> $target" ;;
                  *) echo "[!] .wslconfig のリンク先が dotfiles の wsl/.wslconfig ではありません: $target" ;;
                esac
              else
                echo "[!] $wslconfig は symlink ではありません (apply.ps1 で管理されるべき)"
              fi
            }
          '';
        in
        {
          # perSystem モジュール (treefmt-nix など) が参照する pkgs を
          # x86_64-darwin では 26.05 系スタックに差し替える
          _module.args.pkgs = pkgsFor system;

          devShells = {
            default = pkgs.mkShell {
              name = "dotfiles-default";
              packages = with pkgs; [
                git
                just
              ];
              shellHook = ''
                echo "[devShell:default]"
                git --version
                just --version
              '';
            };

            nix = pkgs.mkShell {
              name = "dotfiles-nix";
              packages = with pkgs; [
                nixfmt-rfc-style
                statix
                deadnix
                nil
                nixd
              ];
              shellHook = ''
                echo "[devShell:nix]"
                nix --version
                nixfmt --version
                statix --version
                deadnix --version
              '';
            };

            editors = pkgs.mkShell {
              name = "dotfiles-editors";
              packages = with pkgs; [
                stylua
                nodejs_24
              ];
              shellHook = ''
                echo "[devShell:editors]"
                stylua --version
                node --version
              '';
            };
          };

          apps = {
            # nix run .#switch
            switch = {
              type = "app";
              program = "${pkgs.writeShellScriptBin "switch" ''
                set -eo pipefail

                ${detectHelpers}

                # 事前チェック: flake の評価エラーを検出
                echo "[pre-flight] nix flake check --no-build ..."
                nix flake check --no-build
                echo ""

                if is_wsl; then
                  echo "  system : WSL (x86_64)"
                  echo "  target : .#${username}-wsl"
                  echo "  cmd    : switch"
                  echo ""
                  check_wslconfig
                  nix run nixpkgs#home-manager -- switch --flake .#${username}-wsl |& ${pkgs.nix-output-monitor}/bin/nom
                elif is_darwin; then
                  echo "  system : ${sysLabel}"
                  echo "  target : ${flakeTarget}"
                  echo "  cmd    : switch"
                  echo ""
                  sudo nix run nix-darwin -- switch --flake ${flakeTarget} |& ${pkgs.nix-output-monitor}/bin/nom
                else
                  echo "  system : ${sysLabel}"
                  echo "  target : ${flakeTarget}"
                  echo "  cmd    : switch"
                  echo ""
                  nix run nixpkgs#home-manager -- switch --flake ${flakeTarget} |& ${pkgs.nix-output-monitor}/bin/nom
                fi
              ''}/bin/switch";
            };

            # nix run .#build
            build = {
              type = "app";
              program = "${pkgs.writeShellScriptBin "build" ''
                set -eo pipefail

                ${detectHelpers}

                if is_wsl; then
                  echo "  system : WSL (x86_64)"
                  echo "  target : .#${username}-wsl"
                  echo "  cmd    : build"
                  echo ""
                  ${pkgs.nix-output-monitor}/bin/nom build .#homeConfigurations.${username}-wsl.activationPackage
                elif is_darwin; then
                  echo "  system : ${sysLabel}"
                  echo "  target : ${hmConfig}"
                  echo "  cmd    : build"
                  echo ""
                  ${pkgs.nix-output-monitor}/bin/nom build .#${hmConfig}
                else
                  echo "  system : ${sysLabel}"
                  echo "  target : ${hmConfig}"
                  echo "  cmd    : build"
                  echo ""
                  ${pkgs.nix-output-monitor}/bin/nom build .#${hmConfig}
                fi
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
          "${username}-wsl" = mkWSLHomeConfig "x86_64-linux";
        };

        # macOS 向け nix-darwin 設定 (Apple Silicon / Intel Mac)
        darwinConfigurations = {
          ${username} = mkDarwinConfig "aarch64-darwin";
          "${username}-x86_64" = mkDarwinConfig "x86_64-darwin";
        };
      };
    };
}
