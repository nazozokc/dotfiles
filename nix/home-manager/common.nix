# common.nix
{ lib, config, myPkgs, ... }:

let
  homeDir = config.home.homeDirectory;
  configHome = config.xdg.configHome;
  dotfilesDir = "${homeDir}/ghq/github.com/nazozokc/dotfiles";

  # ここで myPkgs の各関数を呼び出す
  cliPkgs = with myPkgs.pkgs; [
    myPkgs.cli.core
    myPkgs.cli.git
    myPkgs.cli.misc
    myPkgs.cli.search
  ];

  guiPkgs = with myPkgs.pkgs; [
    myPkgs.gui.editor
    myPkgs.gui.terminal
    myPkgs.gui.misc
  ];

  langPkgs = with myPkgs.pkgs; [
    myPkgs.lang.node
    myPkgs.lang.python
    myPkgs.lang.rust
    myPkgs.tools
  ];

in
{
  ########################################
  # パッケージまとめ
  ########################################
  home.packages = cliPkgs ++ guiPkgs ++ langPkgs;

  ########################################
  # dotfilesリンク
  ########################################
  xdg.configFile = {
    "fish" = { source = "${dotfilesDir}/fish"; force = true; };
    "nvim" = { source = "${dotfilesDir}/nvim"; force = true; };
    "wezterm" = { source = "${dotfilesDir}/wezterm"; force = true; };
  };

  home.activation.linkDotfilesCommon =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      echo "linking extra dotfiles (force)"

      ln -sfn "${dotfilesDir}/pip" "${homeDir}/.pip"
      ln -sfn "${dotfilesDir}/my_scripts" "${homeDir}/.scripts"
    '';

  ########################################
  programs.fish.enable = true;
  programs.neovim.enable = true;
  programs.wezterm.enable = true;
  xdg.enable = true;
  programs.home-manager.enable = true;
}

