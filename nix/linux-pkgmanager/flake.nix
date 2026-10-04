{
  description = "nix で Linux のパッケージマネージャー (pacman / apt / dnf / zypper / yum) を宣言的に管理する。flake 名は linux-pkgmanager.nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # flake を複数モジュールに分割するためのフレームワーク
    flake-parts.url = "github:hercules-ci/flake-parts";

    # nix fmt (treefmt-nix)
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # checks.<system>.<name> を GitHub Actions の matrix に落とす。
    # CI 専用 (.github/workflows/ci.yaml が読むだけ) なので、値を公開 API には出さない
    nix-github-actions = {
      url = "github:nix-community/nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-parts,
      nix-github-actions,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      # 5 pm の定義 (nix/lib/backends.nix)
      backends = import ./nix/lib/backends.nix;

      pms = lib.attrNames backends;

      # 宣言の検査 (nix/lib/declared.nix)。
      # apps / checks / lib.mkNlp の 3 経路が同じ検査を通す
      #
      # check    : 問題を文字列のリストで返すだけ (throw しない)。テスト用
      # validate : check の結果を throw に変換する。本番用
      declaredCheck = import ./nix/lib/declared.nix { inherit lib backends; };
      inherit (declaredCheck) check validate;

      # このリポジトリ自身の宣言 (packages/<pm>.nix)。
      # 単体で `nix run .#diff` を実行するときのもの。
      # ここで一度検証するので apps / checks は受け取った値そのまま使える
      declared = validate (lib.genAttrs pms (pm: import ./packages/${pm}.nix));

      # 公開するモジュール。flakeModules に出力し、
      # _module.args にも同じ値に入れる。
      #
      # 2 箇所に書くと「公開しているファイル」と「検査しているファイル」が
      # 別のものになりうる。公開 API の check が意味を失うので 1 箇所に寄せる
      flakeModule = ./nix/flake-module.nix;
      homeManagerModule = ./nix/home-manager-module.nix;

      # flake-parts が出力全体。下の outputs へそのまま混ぜて公開する
      parts = flake-parts.lib.mkFlake { inherit inputs; } {
        imports = [
          ./nix/flake-module.nix
          ./nix/flake-parts/checks.nix
          ./nix/flake-parts/treefmt.nix
        ];

        # このリポジトリ自身の宣言。消費側と同じモジュールを通す。
        # 接頭辞は空のままにして、今までの `nix run .#diff` を維持する。
        nlp = {
          declared = lib.genAttrs pms (pm: import ./packages/${pm}.nix);
          appPrefix = "";
          defaultApp = "diff";
        };

        # 実行対象は Linux のみ。
        # pacman / apt / dnf / zypper / yum は Linux のツールなので、
        # darwin を systems に入れても評価する価値がない
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        # app / check から参照する値
        _module.args = {
          inherit
            backends
            check
            declared
            flakeModule
            homeManagerModule
            validate
            ;
        };
      };
    in
    {
      # 配布用の公開 API。
      # 他の flake は flakeModules.default を import して nlp.declared を書く。
      # flake-parts を使わない場合は lib.mkApps / lib.mkNlp (nix/lib/mk-nlp.nix)。
      lib = {
        inherit
          backends
          check
          pms
          validate
          ;
        mkNlp = import ./nix/lib/mk-nlp.nix { inherit lib backends validate; };
        mkApps = import ./nix/lib/mk-apps.nix { inherit lib backends validate; };
      };

      flakeModules = {
        # flake-parts の消費側
        default = flakeModule;
        nlp = flakeModule;

        # home-manager の消費側。home-manager 本体の出力名に揃える。
        # apps は出さず、home.packages に nlp を載せるだけ
        home-manager = homeManagerModule;
        homeManager = homeManagerModule;
        home-manager-nlp = homeManagerModule;
      };

      nixosModules = {
        default = homeManagerModule; # NixOS で home-manager module として使うケースは通常home-manager経由だが互換のため維持
        nlp = homeManagerModule;
      };

      homeManagerModules = {
        default = homeManagerModule;
        nlp = homeManagerModule;
      };

      # CI 用の matrix。.github/workflows/ci.yaml が nix eval で読むだけ
      #
      # attrPrefix を "checks" にするのは、既定値が "githubActions.checks" で
      # そこに無い属性を指してしまうため。CI は
      # `nix build '.#checks.<system>."<name>"'` を実行するので、ここが
      # 一致していないと matrix が実在しない attr を出力する
      githubActions = nix-github-actions.lib.mkGithubMatrix {
        inherit (parts) checks;
        attrPrefix = "checks";

        # 既定の表に任せずはっきり書く。上流が既定値を変えても、
        # CI が黙って別の runner に移らないようにするため
        platforms = {
          # arm64 は GitHub の標準 runner (公開 repo なら追加費用なし)
          "aarch64-linux" = "ubuntu-24.04-arm";
          "x86_64-linux" = "ubuntu-24.04";
        };
      };

      templates = {
        default = {
          path = ./templates/minimal;
          description = "Minimal example using linux-pkgmanager.nix with flake-parts or direct module";
        };
        minimal = {
          path = ./templates/minimal;
          description = "Minimal setup (autoDetect + packages)";
        };
      };
    } // parts;
}
