# nix/modules/home/programs/nvim/plugins/default.nix
# Neovim プラグインの実体とバージョンを Nix store の farm (symlink 一覧) にまとめる。
#
# 正本は nvim/nvim-plug-manage/flake.lock。
#   プラグインを追加する → nvim/lua/plugins/*.lua に宣言して
#                          nix run .#nvim-install  (sync-inputs.lua が input 追加して lock / bump しない)
#   全部更新する         → nix run .#nvim-update   (nix flake update)
#   反映する             → nix run .#switch
#
# flake.lock の narHash は fetchFromGitHub / fetchgit の outputHash と一致する
# (NAR ハッシュは tarball を展開・strip した結果の木そのもので、flake の
#  github/git fetcher と fetchFromGitHub/fetchgit で同じ値になる。実測済み)。
# そのためハッシュを別に管理する必要が無い。
{ pkgs, dotfilesDir }:
let
  inherit (pkgs) lib;

  lock = builtins.fromJSON (builtins.readFile "${dotfilesDir}/nvim/nvim-plug-manage/flake.lock");
  inherit (lock) nodes;

  # nixpkgs 側にビルド手順かパッチがあるプラグインだけ pkgs.vimPlugins から取る。
  # 値は vimPlugins の属性名。これらは nvim/nvim-plug-manage/flake.nix には
  # 入れていない (バージョンは root の nixpkgs input が持つ)。
  #   lazy.nvim                 : lazy 自身の helptags 生成を消すパッチ
  #                               (nix store は read-only なので書けない)
  #   denops.vim                : deno のパスを Nix のものへ焼き込む postPatch
  #   telescope-fzf-native.nvim : libfzf.so を make でビルドする
  fromNixpkgs = {
    "lazy.nvim" = "lazy-nvim";
    "denops.vim" = "denops-vim";
    "telescope-fzf-native.nvim" = "telescope-fzf-native-nvim";
  };

  isPlugin =
    n:
    builtins.elem (nodes.${n}.locked.type or "") [
      "github"
      "git"
    ];

  fetch =
    l:
    if l.type == "github" then
      pkgs.fetchFromGitHub {
        inherit (l)
          owner
          repo
          rev
          ;
        sha256 = l.narHash;
      }
    else
      pkgs.fetchgit {
        inherit (l)
          url
          rev
          ;
        hash = l.narHash;
      };

  # pkgs.vimUtils.buildVimPlugin は使わない。
  # toVimPlugin が neovimRequireCheckHook を preDistPhases へ足すため、
  # 素のソースでは依存プラグイン (plenary / nvim-nio / nvim-cmp ...) を
  # require できず失敗する。nixpkgs は overrides.nix の dependencies で
  # それを埋めているが、lazy.nvim 運用では依存解決は Lua 側
  # (nvim/lua/plugins/*.lua) の仕事なので farm はソースを置くだけでよい。
  #
  # doc/tags だけはビルド時に焼く。store は read-only なので
  # 起動後に lazy.nvim から :helptags を書けないため。
  mkPlugin =
    name: l:
    pkgs.runCommand "vimplugin-${name}-${builtins.substring 0 7 l.rev}"
      {
        nativeBuildInputs = [ pkgs.neovim-unwrapped ];
      }
      ''
        cp -r ${fetch l}/. "$out"
        chmod -R u+w "$out"
        if [ -d "$out/doc" ]; then
          HOME="$TMPDIR" ${pkgs.neovim-unwrapped}/bin/nvim \
            -N -u NONE -i NONE -n -E -s -V1 -c "helptags $out/doc" +quit!
        fi
      '';

  # リンク名は lazy.nvim の plugin.name。
  # init.lua が <farm>/<plugin.name> を dev.path として解決するため、
  # store の basename や nixpkgs の属性名では絶対に合わない。
  entries =
    map (name: {
      inherit name;
      value = mkPlugin name nodes.${name}.locked;
    }) (builtins.filter (n: isPlugin n && !(fromNixpkgs ? n)) (builtins.attrNames nodes))
    ++ lib.mapAttrsToList (name: attr: {
      inherit name;
      value = pkgs.vimPlugins.${attr};
    }) fromNixpkgs;

  # lazy.nvim の dev.path として使う farm: <farm>/<plugin-name>
  farm = pkgs.runCommand "nvim-lazy-plugins" { } ''
    mkdir -p "$out"
    ${lib.concatMapStrings (e: ''
      ln -s ${e.value} "$out/${lib.escapeShellArg e.name}"
    '') entries}
  '';
in
{
  inherit farm;
  path = "${farm}";
  names = map (e: e.name) entries;
  count = builtins.length entries;
}
