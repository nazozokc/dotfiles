{ config, pkgs, ... }:

{
  home.file = {
    ".config/fish" = {
      source = ../fish;
      recursive = true;
      force = true;
    };

    ".config/nvim" = {
      source = ../nvim;
      recursive = true;
      force = true;
    };

    ".config/wezterm" = {
      source = ../wezterm;
      recursive = true;
      force = true;
    };

    ".zshrc" = {
      source = ../zsh/zshrc;
      force = true;
    };
  };
}

