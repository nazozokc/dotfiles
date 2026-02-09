{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "nazozokc";
    userEmail = "you@example.com";
  };
}

