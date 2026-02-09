{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;

    shellAliases = {
      ll = "ls -lah";
      gs = "git status";
      gco = "git checkout";
    };

    interactiveShellInit = ''
      set -g fish_greeting
    '';
  };
}

