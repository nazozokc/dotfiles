{ pkgs, lib, username, ... }:

{
  ########################################
  # nix-darwin 基本設定
  ########################################
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" username ];
    };
  };

  ########################################
  # ユーザー
  ########################################
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.fish;
  };

  ########################################
  # システム全体のパッケージ
  ########################################
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
  ];

  ########################################
  # デフォルトシェル
  ########################################
  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];

  ########################################
  # macOS 設定（最低限）
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
  # セキュリティ / その他
  ########################################
  security.pam.enableSudoTouchIdAuth = true;

  ########################################
  # nix-darwin 自体の state version
  ########################################
  system.stateVersion = 4;
}

