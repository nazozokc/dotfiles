{ config, dotfilesDir, ... }:

let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.file = {
    ".config/fish".source = link "${dotfilesDir}/fish";
    ".config/wezterm".source = link "${dotfilesDir}/wezterm";
    ".zshrc".source = link "${dotfilesDir}/zsh/zshrc";
    ".bashrc".source = link "${dotfilesDir}/bash/bashrc";
    ".scripts".source = link "${dotfilesDir}/my_scripts";
  };
}
