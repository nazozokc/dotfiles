{ config, pkgs, ... }:

{
  home.file = {
    ".config/fish/config.fish".source =
      ../fish/;

    ".config/nvim/init.lua".source =
      ../nvim/;

    ".config/wezterm/wezterm.lua".source =
      ../wezterm/;

    ".zshrc".source =
      ../zsh/;
  };
}

