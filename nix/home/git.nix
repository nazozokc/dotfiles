{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "nazozokc";
        email = "you@example.com";
      };
    };
  };
}

