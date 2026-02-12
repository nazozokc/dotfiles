{ pkgs, lib, username, ... }:

{
  ########################################
  # Nix / nix-darwin 基本
  ########################################
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" username ];
    };
  };

  ########################################
  # ユーザー設定（※ Home Manager とは別）
  ########################################
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.fish;
  };

  ########################################
  # システム全体で使うパッケージ
  ########################################
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
  ];

  ########################################
  # シェル
  ########################################
  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];

  ########################################
  # macOS デフォルト設定
  ########################################
  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };

    dock = {
      autohide = true;
      mru-spaces = false;
      show-recents = false;
    };

    finder = {
      AppleShowAllFiles = true;
      ShowPathbar = true;
      ShowStatusBar = true;
    };
  };

  ########################################
  # セキュリティ
  ########################################
  security.pam.enableSudoTouchIdAuth = true;

  ########################################
  # nix-darwin の state version
  ########################################
  system.stateVersion = 4;
}

