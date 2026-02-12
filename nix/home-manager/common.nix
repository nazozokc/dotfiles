{ pkgs, lib, ... }:

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
  # ~/.config へのシンボリックリンク
  # ※ flake 相対パス（超重要）
  ########################################
  xdg.configFile = {
    "nvim" = {
      source = ./../../nvim;
      force = true;
    };

    "fish" = {
      source = ./../../fish;
      force = true;
    };

    "wezterm" = {
      source = ./../../wezterm;
      force = true;
    };
  };

  ########################################
  # 有効化（挙動だけHMに任せる）
  ########################################
  programs.fish.enable = true;
  programs.neovim.enable = true;
  programs.wezterm.enable = true;
}

