{
  config,
  lib,
  dotfilesDir,
  ...
}:

let
  link = config.lib.file.mkOutOfStoreSymlink;

  # ディレクトリ内の全ファイルを個別に symlink するヘルパー
  # ディレクトリ全体を symlink すると home-manager がそのディレクトリに
  # ファイルをインストールしようとしたとき ($HOME) 外になるため個別に symlink する
  symlinkDir =
    dir: prefix:
    let
      entries = builtins.readDir dir;
      files = lib.filterAttrs (
        name: _: lib.hasSuffix ".fish" name || lib.hasSuffix ".disabled" name
      ) entries;
    in
    lib.mapAttrs' (
      name: _:
      lib.nameValuePair "${prefix}/${name}" {
        source = link "${dir}/${name}";
      }
    ) files;
in
{
  home.file = {
    # NOTE: fish ディレクトリ全体を symlink すると Nix store が read-only のため
    # fish_variables の書き込みが失敗する。個別に symlink して fish_variables だけ
    # Nix 管理から外し、fish に自動生成させる。
    ".config/fish/fish_plugins".source = link "${dotfilesDir}/fish/fish_plugins";
  }
  # conf.d, functions, completions は個別ファイルとして symlink する
  # ディレクトリ全体を symlink すると home-manager が生成するファイル
  # (例: yazi の y.fish) をインストールできない
  // symlinkDir "${dotfilesDir}/fish/conf.d" ".config/fish/conf.d"
  // symlinkDir "${dotfilesDir}/fish/functions" ".config/fish/functions"
  // symlinkDir "${dotfilesDir}/fish/completions" ".config/fish/completions"
  // {
    ".config/wezterm".source = link "${dotfilesDir}/wezterm";
    ".config/efm-langserver" = {
      source = link "${dotfilesDir}/efm-langserver";
      force = true;
    };
    ".config/mise/config.toml".source = link "${dotfilesDir}/mise.toml";
    ".zshrc".source = link "${dotfilesDir}/zsh/zshrc";
    ".bashrc".source = link "${dotfilesDir}/bash/bashrc";
    ".scripts".source = link "${dotfilesDir}/my_scripts";
  };
}
