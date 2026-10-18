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
  networking = {
    hostName = username;
    networkmanager.enable = true;
  };

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
    ];
    shell = pkgs.fish;
  };

  # ---- グラフィックス --------------------------------------------------------
  # Wayland / Hyprland / Ambxst に必須。Mesa と /run/opengl-driver を有効化する。
  # nixGL は不要 (NixOS はドライバを OS 層で配線する)。
  hardware.graphics.enable = true;

  # ---- 音声 -----------------------------------------------------------------
  # pipewire + pulse 互換 (Ambxst / pavucontrol は pulse ソケットを使う)。
  # 最小構成: JACK / ALSA の追加機能は有効化しない
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # ---- 電源管理 -------------------------------------------------------------
  # power.nix (system-manager 用) は systemd.packages + wantedBy で
  # ppd を動かすが、NixOS にはネイティブの services.power-profiles-daemon が有る。
  services.power-profiles-daemon.enable = true;

  # ---- Nix 設定 -------------------------------------------------------------
  # NixOS は nix-command / flakes を既定で有効化しているが、明示しておく
  # (将来のデフォルト変更に依存しないため)。
  # trusted-users に username を足すことで sudo 無しで substituter 利用等が可能に。
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      username
    ];
  };

  # ---- stateVersion ---------------------------------------------------------
  # 初回インストール時のリリースに合わせる。以後絶対に変更しない
  # (home.stateVersion と同じポリシー)。
  system.stateVersion = "26.11";
}
