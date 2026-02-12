{ pkgs, lib, username, ... }:

let
  homeDir =
    if pkgs.stdenv.isDarwin
    then "/Users/${username}"
    else "/home/${username}";

  dotfilesDir = "${homeDir}/ghq/github.com/nazozokc/dotfiles";
in
{
  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "24.05";

  ########################################
  # パッケージ管理だけ
  ########################################
  home.packages = with pkgs; [
    neovim
    fish
    wezterm
    git
    gh
    ripgrep
    fd
  ];

  ########################################
  # .config へのシンボリックリンク
  ########################################
  xdg.configFile = {
    "nvim".source = "${dotfilesDir}/nvim";
    "fish".source = "${dotfilesDir}/fish";
    "wezterm".source = "${dotfilesDir}/wezterm";
  };

  ########################################
  # 有効化だけ（設定は読まない）
  ########################################
  programs.fish.enable = true;
  programs.neovim.enable = true;
  programs.wezterm.enable = true;

  xdg.enable = true;
  programs.home-manager.enable = true;
}

