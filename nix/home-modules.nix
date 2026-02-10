{ config, pkgs, ... }:

{
  home.file = {
    ".config/fish".source =
      ../fish;

    ".config/nvim".source =
      ../nvim;

    ".config/wezterm".source =
      ../wezterm;

    ".zshrc".source =
      ../zsh/zshrc;
  };
}

