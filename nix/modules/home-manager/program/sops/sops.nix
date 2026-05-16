{ config, pkgs, ... }:

let
  homeDir = config.home.homeDirectory;
in
{
  sops = {
    age = {
      keyFile = "${homeDir}/.config/sops/age/keys.txt";
      generateKey = false;
    };

    secrets = { };
  };
}
