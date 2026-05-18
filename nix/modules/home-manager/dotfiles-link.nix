{ config, dotfilesDir, ... }:

let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.file = {
    "commitlint.config.js".source = link "${dotfilesDir}/commitlint.config.js";
    ".config/fish".source = link "${dotfilesDir}/fish";
    ".config/wezterm".source = link "${dotfilesDir}/wezterm";
    ".zshrc".source = link "${dotfilesDir}/zsh/zshrc";
    ".bashrc".source = link "${dotfilesDir}/bash/bashrc";
    ".scripts".source = link "${dotfilesDir}/my_scripts";
  };
}
