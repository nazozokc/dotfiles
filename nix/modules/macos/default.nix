# nix/modules/macos/default.nix
# macOS 固有の nix-darwin 設定
{ pkgs, username, ... }:

{
  ########################################
  # nix-darwin 基本設定
  ########################################
  system.stateVersion = 4;
  system.primaryUser = username;

  ########################################
  # Nix 設定の強化
  ########################################
  nix = {
    gc = {
      automatic = true;
      interval.Day = 1;
      options = "--delete-older-than 30d";
    };
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      always-allow-substitutes = true;
      max-jobs = "auto";
      trusted-users = [ username ];
    };
  };

  ########################################
  # ユーザー定義
  ########################################
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.fish;
    ignoreShellProgramCheck = true;
  };

  environment.shells = [ pkgs.fish ];

  ########################################
  # シェル
  ########################################
  programs.fish.enable = true;

  ########################################
  # macOS セキュリティ / 権限
  ########################################
  security.pam.services.sudo_local.touchIdAuth = true;

  ########################################
  # macOS システム設定（詳細）
  ########################################
  system.defaults = {
    # Dock
    dock = {
      autohide = true;
      tilesize = 45;
      persistent-apps = [ ];
      show-recents = false;
      mineffect = "genie";
      orientation = "bottom";
    };

    # Finder
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
    };

    # グローバル設定
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      KeyRepeat = 2;
      InitialKeyRepeat = 25;
      "com.apple.trackpad.scaling" = 1.3;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };

    # スクリーンショット
    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "png";
    };

    # トラックパッド
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = false;
    };
  };

  ########################################
  # フォント
  ########################################
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  ########################################
  # macOS 固有ツール
  ########################################
  environment.systemPackages = with pkgs; [
    blueutil
    git
    mas
    switchaudio-osx
    terminal-notifier
  ];

  ########################################
  # プログラム設定
  ########################################
  programs = {
    nix-index.enable = true;
  };
}
