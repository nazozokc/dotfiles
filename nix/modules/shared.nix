{ config, pkgs, lib, ... }:

{
  home.username = "nazozokc";

  home.homeDirectory =
    if pkgs.stdenv.isDarwin
    then "/Users/nazozokc"
    else "/home/nazozokc";

  # stateVersion は強制
  home.stateVersion = lib.mkForce "24.05";
}

