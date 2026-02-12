{ pkgs, lib, username, ... }:

{
  ########################################
  # パッケージ（最低限）
  ########################################
  home.packages = with pkgs; [
    fish
    wezterm
    git
    gh
    ripgrep
    fd
  ];

  ########################################
  # .config へのシンボリックリンク
  # ※ flake 相対パスを使う（超重要）
  ########################################
  xdg.configFile = {
    "nvim".source = ./../../nvim;
    "fish".source = ./../../fish;
    "wezterm".source = ./../../wezterm;
  };

  ########################################
  # 有効化だけ
  ########################################
  programs.fish.enable = true;
  programs.neovim.enable = true;
  programs.wezterm.enable = true;
}

