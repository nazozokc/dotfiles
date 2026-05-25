{ config, dotfilesDir, ... }:

let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.file = {
    # NOTE: fish ディレクトリ全体を symlink すると Nix store が read-only のため
    # fish_variables の書き込みが失敗する。個別に symlink して fish_variables だけ
    # Nix 管理から外し、fish に自動生成させる。
    ".config/fish/fish_plugins".source = link "${dotfilesDir}/fish/fish_plugins";
    ".config/fish/conf.d".source = link "${dotfilesDir}/fish/conf.d";
    ".config/fish/functions".source = link "${dotfilesDir}/fish/functions";
    ".config/fish/completions".source = link "${dotfilesDir}/fish/completions";
    ".config/wezterm".source = link "${dotfilesDir}/wezterm";
    ".zshrc".source = link "${dotfilesDir}/zsh/zshrc";
    ".bashrc".source = link "${dotfilesDir}/bash/bashrc";
    ".scripts".source = link "${dotfilesDir}/my_scripts";
  };
}
