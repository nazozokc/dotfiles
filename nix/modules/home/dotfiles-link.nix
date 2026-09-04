{
  config,
  lib,
  dotfilesDir,
  ...
}:

let
  # dotfilesDir が文字列であることを保証 (Nix path リテラルだと flake で壊れる)
  dotfilesDirStr = builtins.toString dotfilesDir;

  link = config.lib.file.mkOutOfStoreSymlink;

  # ディレクトリ内の全ファイルを個別に symlink するヘルパー
  # ディレクトリ全体を symlink すると home-manager がそのディレクトリに
  # ファイルをインストールしようとしたとき ($HOME) 外になるため個別に symlink する
  symlinkDir =
    dir: prefix:
    let
      dirStr = builtins.toString dir;
      entries = builtins.readDir dir;
      files = lib.filterAttrs (
        name: _: lib.hasSuffix ".fish" name || lib.hasSuffix ".disabled" name
      ) entries;
    in
    lib.mapAttrs' (
      name: _:
      lib.nameValuePair "${prefix}/${name}" {
        source = link "${dirStr}/${name}";
      }
    ) files;
in
{
  home.file = {
    # NOTE: fish ディレクトリ全体を symlink すると Nix store が read-only のため
    # fish_variables の書き込みが失敗する。個別に symlink して fish_variables だけ
    # Nix 管理から外し、fish に自動生成させる。
    ".config/fish/fish_plugins".source = link "${dotfilesDirStr}/fish/fish_plugins";
  }
  # conf.d, functions, completions は個別ファイルとして symlink する
  # ディレクトリ全体を symlink すると home-manager が生成するファイル
  # (例: yazi の y.fish) をインストールできない
  // symlinkDir "${dotfilesDirStr}/fish/conf.d" ".config/fish/conf.d"
  // symlinkDir "${dotfilesDirStr}/fish/functions" ".config/fish/functions"
  // symlinkDir "${dotfilesDirStr}/fish/completions" ".config/fish/completions"
  // {
    ".config/wezterm".source = link "${dotfilesDirStr}/wezterm";
    ".config/efm-langserver" = {
      source = link "${dotfilesDirStr}/efm-langserver";
      force = true;
    };
    ".config/mise/config.toml".source = link "${dotfilesDirStr}/mise.toml";
    ".zshrc".source = link "${dotfilesDirStr}/zsh/zshrc";
    ".bashrc".source = link "${dotfilesDirStr}/bash/bashrc";
    ".scripts".source = link "${dotfilesDirStr}/my_scripts";
  };
}
