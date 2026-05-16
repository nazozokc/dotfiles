{
  config,
  pkgs,
  lib,
  ...
}:

let
  homeDir = config.home.homeDirectory;
in
{
  sops = lib.mkIf pkgs.stdenv.isLinux {
    age = {
      keyFile = "${homeDir}/.config/sops/age/keys.txt";
      generateKey = false;
    };

    secrets = { };
  };
}
