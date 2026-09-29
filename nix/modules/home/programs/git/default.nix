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

    # Platform-specific signing (SSH key path differs per platform).
    # Kept OFF: signing needs an SSH key under ~/.ssh and this machine has
    # none (only known_hosts). With signByDefault on, home-manager emits
    # tag.gpgsign = true, which git/config never overrides, so every
    # `git tag` dies with:
    #   fatal: either user.signingkey or gpg.ssh.defaultKeyCommand needs to be configured
    # To turn signing on: create a key, point `key` at it per platform here,
    # and drop `gpgSign = false` from git/config.
    signing = {
      format = "ssh";
      signByDefault = false;
      key = null;
    };

    # Keep minimal platform-specific settings here;
    # all common settings are in git/config (deployed below)
    settings = {
      # wt.remover uses nix-store path to trash-cli.
      # Do NOT re-add `wt.remover` to git/config: includes are appended after
      # these settings, so a value there silently overrides this one.
      wt.remover = trash;
    };

    # Only shared-config belongs here. git/config already pulls in
    # ~/.config/git/aliases with its own [include], and listing it here too
    # made `git config --get-all alias.l` return every alias twice.
    includes = [
      {
        path = "~/.config/git/shared-config";
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
