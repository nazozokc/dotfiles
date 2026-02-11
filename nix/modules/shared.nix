{ config, pkgs, lib, ... }:

{
  home.username = "nazozokc";

  home.homeDirectory =
    if pkgs.stdenv.isDarwin
    then "/Users/nazozokc"
    else "/home/nazozokc";

  home.stateVersion = "24.05";
}

