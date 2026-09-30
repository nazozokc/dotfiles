{
  description = "nazozo dotfiles (multi-system, apps + nom)";

  # ---------------------------------------------------------------------------
  # Binary cache: この flake では設定しない (cache.nixos.org のみ)
  #
  # Nix 2.35 では nixConfig は client-specified 設定として扱われ、
  # restricted setting (substituters / trusted-public-keys) は
  # Trusted User でないクライアントから渡せない。
  #   → extra-substituters / extra-trusted-public-keys は無視される
  #   → `ignoring untrusted substituter` 警告が出るだけで効かない
  #
  # cache.nixos.org は Nix が信頼済みとしてハードコードしているため
  # 追加の substituters 設定は不要。
  # サードパーティ cache を使いたい場合は
  # /etc/nix/nix.conf (OS 層 = system-manager) 側で設定する。
  # ---------------------------------------------------------------------------

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

    # Zen Browser (nixpkgs には無いので upstream バイナリを wrap した flake を使う)
    # x86_64-linux / aarch64-linux のみ提供
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # GPU ライブラリラッパー (非 NixOS で Nix GUI アプリを動かす)
    nixGL = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Ambxst (Quickshell 製デスクトップシェル)
    # 独自 nixosModules は upower / power-profiles-daemon / NetworkManager を
    # mkDefault true で強制するため採用しない (nix/modules/system/power.nix と
    # 二重定義になる)。使うのは packages.<system>.default のみ。
    ambxst = {
      url = "github:Axenide/Ambxst";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Linux OS 設定管理 (非 NixOS ディストリで NixOS モジュールを扱えるようにする)
    # macOS 側の nix-darwin に相当する役割
    system-manager = {
      url = "github:numtide/system-manager";
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
  #
  # このファイルが持つのは「配線」だけ。
  #   - 値の定義             → nix/lib/   (identity / pkgs / shell / targets)
  #   - devShells と apps    → nix/flake-parts/
  #   - ユーザー層・OS 層の設定 → nix/modules/{linux,wsl,macos,system}/build.nix
  #
  # `nix run github:nazozokc/dotfiles` (apps.default) の実体は
  # nix/flake-parts/apps/bootstrap.nix にある。
  # ---------------------------------------------------------------------------
  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      home-manager,
      darwin,
      nix-index-database,
      agent-skills-nix,
      sops-nix,
      nixGL,
      zen-browser,
      system-manager,
      ambxst,
      # x86_64-darwin (Intel Mac) 専用スタック
      nixpkgs-intel,
      home-manager-intel,
      darwin-intel,
      llm-agents,
      llm-agents-intel,
      gh-graph,
      gh-graph-intel,
      gh-nippou,
      gh-nippou-intel,
      ...
    }:
    let
      # ユーザー名と clone 先の所有者 (nix/lib/identity.nix)
      identity = import ./nix/lib/identity.nix;
      inherit (identity) username;

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
          zen-browser
          ambxst
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

      # Linux 向け OS 層設定生成 (nix/modules/system/build.nix)
      # systemd ベースの全 Linux ディストロが同じモジュール構成を使う。
      # プラットフォーム差分は nixpkgs.hostPlatform のみ。
      mkSystemConfig = import ./nix/modules/system/build.nix {
        inherit
          system-manager
          username
          ;
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {

      imports = [
        # apps (default=bootstrap / switch / build / update / system-*)
        ./nix/flake-parts/apps/bootstrap.nix
        ./nix/flake-parts/apps/switch.nix
        ./nix/flake-parts/apps/build.nix
        ./nix/flake-parts/apps/update.nix
        ./nix/flake-parts/apps/system.nix
        ./nix/flake-parts/dev-shells.nix
        # nix fmt (treefmt-nix)
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
      #
      # ここは pkgs の注入だけ。アプリ・devShell の実体は nix/flake-parts/ に置き、
      # imports で読み込む。
      # -------------------------------------------------------------------
      perSystem =
        { system, ... }:
        {
          # perSystem モジュール (treefmt-nix / nix/flake-parts/*) が参照する pkgs。
          # x86_64-darwin では 26.05 系スタックに差し替える。
          _module.args.pkgs = pkgsFor system;
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

        # -------------------------------------------------------------------
        # Linux 向け OS 層設定 (system-manager)
        # -------------------------------------------------------------------
        # home-manager が扱えない /etc・systemd システムユニット等を宣言的に管理する。
        # macOS 側の nix-darwin に相当する役割。
        #
        # 命名は homeConfigurations に揃える:
        #   nazozokc         → x86_64-linux (デスクトップ / VPS などのネイティブ)
        #   nazozokc-aarch64 → aarch64-linux (ARM Linux)
        #
        # プラットフォームを固定する理由:
        #   nix/modules/system/build.nix が nixpkgs.hostPlatform を設定するため、
        #   この derivation の評価は実行マシンに依存しない。
        #   → `nix flake check` を macOS CI で走らせても Linux 向け設定の
        #     評価結果が壊れない
        systemConfigs = {
          ${username} = mkSystemConfig "x86_64-linux";
          "${username}-aarch64" = mkSystemConfig "aarch64-linux";
        };
      };
    };
}
