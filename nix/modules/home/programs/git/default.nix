{
  pkgs,
  lib,
  dotfilesDir,
  ...
}:
let
  trash = lib.getExe pkgs.trash-cli;
in
{
  programs.git = {
    enable = true;

    lfs.enable = true;

    # Platform-specific signing (SSH key path differs per platform)
    signing = {
      format = "ssh";
      signByDefault = true;
      key = null;
    };

    # Keep minimal platform-specific settings here;
    # all common settings are in git/config (deployed below)
    settings = {
      # wt.remover uses nix-store path to trash-cli
      wt.remover = trash;
    };

    # Include shared config files
    includes = [
      {
        path = "~/.config/git/shared-config";
      }
      {
        path = "~/.config/git/aliases";
      }
    ];
  };

  programs.delta = {
    enable = true;
    # Delta config is managed in git/config shared file
  };

  # Deploy shared git config files
  home.file = {
    ".config/git/shared-config".source = "${dotfilesDir}/git/config";
    ".config/git/aliases".source = "${dotfilesDir}/git/aliases";
    ".config/git/ignore".source = "${dotfilesDir}/git/ignore";
  };
}
