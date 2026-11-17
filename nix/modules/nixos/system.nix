# nix/modules/nixos/system.nix
# NixOS 固有の OS 層設定
#
# system-manager 用の nix/modules/system/ とは役割分担:
#   - sysctl / fcitx5 / locale.gen … 共有モジュールが environment.etc で管理
#     (replaceExisting の有無で両対応済み)
#   - locale.conf / vconsole.conf … NixOS は i18n / console モジュールが
#     environment.etc.source で無条件生成するため、ネイティブオプションが正
#     (共有 locale.nix 側は isSystemManager 判定で自動 skip される)
{
  pkgs,
  username,
  ...
}:

{
  # ---- ネットワーク --------------------------------------------------------
  # hostName はホスト固有値なので nix/hosts/<name>/default.nix が持つ
  networking.networkmanager.enable = true;

  # ---- ロケール / コンソール ------------------------------------------------
  # NixOS は glibcLocales パッケージ方式のため locale-gen は不要。
  # i18n.defaultLocale が /etc/locale.conf と locale-archive の両方を担う。
  # extraLocales は supportedLocales の後継 (deprecated のため使わない)。
  i18n = {
    defaultLocale = "ja_JP.UTF-8";
    extraLocales = [ "en_US.UTF-8/UTF-8" ];
  };
  # console モジュールが /etc/vconsole.conf を生成する (共有 locale.nix は skip)
  console.keyMap = "jp";

  time.timeZone = "Asia/Tokyo";

  # ---- ユーザー -------------------------------------------------------------
  # mutableUsers は既定 true のまま (インストーラーで設定したパスワードを保持する)。
  # shell は home-manager 側と揃える (fish)
  # programs.fish.enable は users.users.<name>.shell の検証で必須
  # (無効だと fish が PATH を持てずログイン不能になる)
  programs.fish.enable = true;
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "input"
      # virtualisation.docker の daemon socket (docker グループ所属で許可)
      "docker"
    ];
    shell = pkgs.fish;
  };

  # ---- デスクトップ (Wayland) -------------------------------------------------
  # Hyprland 本体は pacman / home-manager 側には無く、NixOS は OS 層の
  # programs.hyprland が正。hyprland パッケージ + xdg-desktop-portal-hyprland +
  # security.wrappers.Hyprland (SCHED_RR 用) がまとめて入る。
  # Ambxst の hyprland.lua が Hyprland 0.55+ の Lua 設定 API を要求するため、
  # unstable の新しい版を使うここの nixpkgs が要件も満たす。
  programs.hyprland.enable = true;

  # Hyprland モジュールは xdg-desktop-portal-hyprland (screencast 等) だけを
  # 入れる。ファイル選択ダイアログ / 設定 Interface 用の一般ポータルは
  # GTK 版を別途足す (リスト型なので merge して両方入る)。
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # ---- セキュリティ ----------------------------------------------------------
  # polkit: 認証ダイアログのバックエンド。エージェント (polkit_gnome) は
  # home-packages 側 (nix/modules/linux/packages.nix) が持つ。
  security.polkit.enable = true;

  # PipeWire に推奨: 音声スレッドへ SCHED_RR (リアルタイム優先度) を許可する。
  # これが無いと再生パスで xrun (音切れ) が出る
  security.rtkit.enable = true;

  # ---- Bluetooth -------------------------------------------------------------
  # Ambxst が blueman (BT 管理 GUI) を同梱しており、BT 操作は OS 層の
  # bluetoothd を要求する。nixpkgs 既定は bluetoothd 未起動なので明示する
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # ---- Docker -----------------------------------------------------------------
  # home.packages には docker CLI (+ lazydocker) を入れてある。
  # NixOS では daemon / socket / docker グループを作るのが OS 層の役割。
  # (ユーザーの docker グループ所属は上の users.users で宣言済み)
  virtualisation.docker.enable = true;

  # ---- グラフィックス --------------------------------------------------------
  # Wayland / Hyprland / Ambxst に必須。Mesa と /run/opengl-driver を有効化する。
  # nixGL は不要 (NixOS はドライバを OS 層で配線する)。
  hardware.graphics.enable = true;

  # ---- システムサービス -----------------------------------------------------
  services = {
    # 音声: pipewire + pulse 互換 (Ambxst / pavucontrol は pulse ソケットを使う)。
    # 最小構成: JACK / ALSA の追加機能は有効化しない
    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    # 電源管理: power.nix (system-manager 用) は systemd.packages + wantedBy で
    # ppd を動かすが、NixOS にはネイティブの services.power-profiles-daemon が有る。
    power-profiles-daemon.enable = true;

    # Ambxst (Quickshell) のバッテリー / 電源ウィジェットは UPower の D-Bus
    # インターフェースを参照する。NixOS 既定では無効なので明示する。
    upower.enable = true;

    # SSD の TRIM を週次で実行する。NixOS 既定は無効。
    fstrim.enable = true;

    # ファイルマネージャ / ポータルからドライブをマウントするための daemon。
    udisks2.enable = true;

    # GIO の VFS (ゴミ箱・リモート・最近使ったファイル)。GTK 系アプリの
    # ファイル選択ダイアログが gvfs を要求するため有効化する。
    gvfs.enable = true;
  };

  # ---- Nix 設定 -------------------------------------------------------------
  nix = {
    # NixOS は nix-command / flakes を既定で有効化しているが、明示しておく
    # (将来のデフォルト変更に依存しないため)。
    # trusted-users に username を足すことで sudo 無しで substituter 利用等が可能に。
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        username
      ];
      # store 内の同一ファイルを hardlink で共有する (home-manager の
      # auto-optimise-store 相当)。GC の前に回すと削除対象が減る。
      auto-optimise-store = true;
    };

    # システムプロファイルの GC。home-manager 側のユーザープロファイル GC
    # (systemd/user の nix-store-gc・weekly) と同じ週次で回す。
    # --delete-older-than 14d: 14 日より古い世代を削る。
    # 直近の世代は残るので rollback は保つ
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    # hardlink 最適化を週次で自動実行する。gc と同じ頻度に揃える。
    optimise = {
      automatic = true;
      dates = "weekly";
    };
  };

  # ---- stateVersion ---------------------------------------------------------
  # 初回インストール時のリリースに合わせる。以後絶対に変更しない
  # (home.stateVersion と同じポリシー)。
  system.stateVersion = "26.11";
}
