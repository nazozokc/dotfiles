# nix/flake-module.nix
# 消費側の flake に import する flake-parts モジュール。
#
#   imports = [ inputs.linux-pkgmanager.nix.flakeModules.default ];
#   nlp.declared.pacman = [ "man-db" "bash-completion" ];
#   nlp.declared.apt = ./packages/apt.nix;      # ファイルでも書ける
#
# 評価すると packages.nlp と
# apps.nlp-diff / nlp-adopt / nlp-apply / nlp-update / nlp-status が出る。
# 導入そのものは sudo が要るホスト操作なので、評価や build では走らない。
# `nix run .#nlp-apply` が、この flake の宣言を焼き込んだ実行体になる。
#
# オプションは flake 直下に置く。宣言は system ではなくホストの pm の話なので、
# perSystem に分けても増える情報がない。
{
  config,
  lib,
  ...
}:
let
  backends = import ./lib/backends.nix;
  inherit (import ./lib/declared.nix { inherit lib backends; }) validate;
  mkNlp = import ./lib/mk-nlp.nix { inherit lib backends validate; };
  normalize = import ./lib/normalize.nix { inherit lib backends; };

  commandNames = [
    "diff"
    "adopt"
    "apply"
    "update"
    "status"
  ];
in
{
  options.nlp = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        false にすると packages.nlp と apps を出さない。
        モジュールを import しただけで出力を足したくないときの逃げ道。
      '';
    };

    # High-level
    autoDetect = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "実行環境で利用可能なパッケージマネージャーを自動検出して有効化";
    };

    commonPackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "全ての有効マネージャーに共通して追加するパッケージ一覧";
    };

    packages = lib.mkOption {
      type = lib.types.attrsOf (lib.types.either (lib.types.listOf lib.types.str) lib.types.path);
      default = { };
      description = "マネージャー別パッケージ一覧 (トップレベルで集約)";
    };

    managers = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options.enable = lib.mkEnableOption "このマネージャーを有効化する";
      });
      default = { };
      description = "有効マネージャーを明示的に指定する";
    };

    update = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "更新機能を有効にする";
          onActivation = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "activation 時の自動更新（安全側でデフォルトfalse）";
          };
          flags = lib.mkOption {
            type = lib.types.attrsOf (lib.types.listOf lib.types.str);
            default = { };
          };
        };
      };
      default = { };
    };

    # Low-level
    declared = lib.mkOption {
      # リストでもファイルでも書ける。ファイルは評価時に import される
      type = lib.types.attrsOf (lib.types.either (lib.types.listOf lib.types.str) lib.types.path);
      default = { };
      example = {
        pacman = [
          "man-db"
          "bash-completion"
        ];
        apt = ./packages/apt.nix;
      };
      description = ''
        パッケージマネージャー名からパッケージ名リストへの宣言（Low-level）。
        書いた pm だけを使う。書かなかった pm は空リストとして扱う。
        未知の pm 名と、pm が受理できないパッケージ名は評価時に落ちる。
      '';
    };

    appPrefix = lib.mkOption {
      type = lib.types.str;
      default = "nlp-";
      example = "nlp-";
      description = ''
        生成する app 名の接頭辞。
        既定の `nlp-` は、消費側がもともと持っている `apps.diff` を潰さないため。
        空文字にすると `diff` / `apply` / `update` / `status` になる。
      '';
    };

    defaultApp = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum commandNames);
      default = null;
      example = "diff";
      description = ''
        設定すると `apps.default` をそのコマンドにする。
        消費側の `apps.default` を勝手に奪わないよう、既定は null。
      '';
    };
  };

  config.perSystem =
    { pkgs, ... }:
    let
      normalize = import ./lib/normalize.nix { inherit lib backends; };
      declaredNormalized =
        if config.nlp.declared != { } then
          config.nlp.declared
        else
          normalize.normalizeDeclared {
            enable = true;
            inherit (config.nlp) autoDetect commonPackages packages managers;
          };
      built = import ./lib/apps.nix {
        inherit lib pkgs;
        nlp = mkNlp {
          inherit pkgs;
          declared = declaredNormalized;
        };
        inherit (config.nlp) appPrefix defaultApp;
      };
    in
    {
      # perSystem のモジュールとして返す。mkIf をモジュール全体に掛けると
      # flake-parts の deferredModule が option 定義と取り違えるので、
      # config だけを条件にする
      config = lib.mkIf config.nlp.enable {
        packages.nlp = built.package;
        inherit (built) apps;
      };
    };
}
