# nix/modules/macos/system.nix
# macOS 固有の nix-darwin 設定（システムレベル）
{ pkgs, username, ... }:

{
  ########################################
  # nix-darwin 基本設定
  ########################################
  system = {
    stateVersion = 4;
    primaryUser = username;

    ########################################
    # macOS システム設定（詳細）
    ########################################
    defaults = {
      # Dock
      dock = {
        autohide = true;
        tilesize = 45;
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
  };

  # 既存 Nix インストールの nixbld GID に合わせる
  ids.gids.nixbld = 350;

  ########################################
  # Nix GC
  ########################################
  nix.gc = {
    automatic = true;
    interval.Day = 1;
    options = "--delete-older-than 30d";
  };

  ########################################
  # ユーザー定義
  ########################################
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.fish;
    ignoreShellProgramCheck = true;
  };

  ########################################
  # シェル
  ########################################
  programs = {
    fish.enable = true;
    nix-index.enable = true;
  };

  ########################################
  # macOS セキュリティ / 権限
  ########################################
  security.pam.services.sudo_local.touchIdAuth = true;

  ########################################
  # フォント
  ########################################
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  ########################################
  # macOS 固有ツール
  ########################################
  environment = {
    shells = [ pkgs.fish ];
    systemPackages = with pkgs; [
      blueutil
      git
      mas
      switchaudio-osx
      terminal-notifier
      keycastr
    ];
  };
}
