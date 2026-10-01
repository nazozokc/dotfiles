# nix/modules/home/programs/nvim/plugins/default.nix
# Neovim プラグインの「実体」と「バージョン」を Nix で持つ。
#
# 考え方
# ------
# lazy.nvim は plugin manager として残す。ただし install 先の directory は
# Nix store にする。実体は 2 系統:
#
#   1. nixpkgs 由来 (./nixpkgs-plugins.nix)
#      → pkgs.vimPlugins.<attr> をそのまま使う。バージョンは nixpkgs に追従する。
#   2. pin 済み (./pinned-plugins.json)
#      → fetchgit で rev 固定。nixpkgs に無い / 追従させたくないもの。
#
# 2 つを `share/nvim/lazy/<プラグイン名>` という 1 つの farm にまとめる。
# nvim/lua/plugins/*.lua 側は一切変更せず、init.lua が
# `LAZY_NIX_PLUGINS` 経由で lazy.nvim の `dev.path` に渡すだけ。
# farm に無いプラグイン (Nix 管理外の swagger-preview.nvim) は
# lazy.nvim の `dev.fallback` により通常の root へ落ちる。
{ pkgs }:
let
  inherit (pkgs) lib;

  nixpkgsPlugins = import ./nixpkgs-plugins.nix;
  pinnedSpecs = builtins.fromJSON (builtins.readFile ./pinned-plugins.json);

  # ---------------------------------------------------------------------
  # 1. nixpkgs 由来
  # ---------------------------------------------------------------------
  fromNixpkgs = name: attr: pkgs.vimPlugins.${attr};

  # ---------------------------------------------------------------------
  # 2. pin 済み
  # ---------------------------------------------------------------------
  # lazy.nvim の build step は store (read-only) 上で実行できず、
  # nvim-treesitter / telescope-fzf-native のようなコンパイルが必要な
  # プラグインは nixpkgs 側を使う前提。ここでは「展開 + doc/tags 生成」だけ。
  fromPinned =
    name: spec:
    pkgs.stdenvNoCC.mkDerivation {
      pname = "vim-plugin-${lib.replaceStrings [ "." ] [ "-" ] name}";
      version = lib.substring 0 8 spec.rev;
      src = pkgs.fetchgit {
        inherit (spec) url rev hash;
      };
      nativeBuildInputs = [ pkgs.neovim ];
      dontConfigure = true;
      dontBuild = true;
      dontFixup = true;
      installPhase = ''
        runHook preInstall

        mkdir -p "$out"
        cp -r ./. "$out"
        chmod -R u+w "$out"

        # nixpkgs の vimPlugin 相当。:help が使えるように helptags を作る。
        if [ -d "$out/doc" ]; then
          nvim --headless -u NONE -c "helptags $out/doc" -c "qa!" >/dev/null
        fi

        runHook postInstall
      '';
    };

  nixpkgsEntries = map (name: {
    inherit name;
    value = fromNixpkgs name nixpkgsPlugins.${name};
  }) (builtins.attrNames nixpkgsPlugins);

  pinnedEntries = map (name: {
    inherit name;
    value = fromPinned name pinnedSpecs.${name};
  }) (builtins.attrNames pinnedSpecs);

  allEntries = nixpkgsEntries ++ pinnedEntries;

  # ---------------------------------------------------------------------
  # farm: <farm>/<プラグイン名> が 1 つの runtimepath エントリになる
  # ---------------------------------------------------------------------
  farm = pkgs.runCommand "nvim-lazy-plugins" { } ''
    mkdir -p "$out"
    ${lib.concatMapStrings (e: ''
      ln -s ${e.value} "$out/${lib.escapeShellArg e.name}"
    '') allEntries}
  '';
in
{
  inherit farm;

  # init.lua へ渡す env 変数の値
  path = "${farm}";

  # 検証用 (updater / ドキュメント)
  names = map (e: e.name) allEntries;
  count = builtins.length allEntries;
}
