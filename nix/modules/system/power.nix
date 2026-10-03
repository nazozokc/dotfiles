# nix/modules/system/power.nix
# 電源管理 (power-profiles-daemon)
#
# power-profiles-daemon (ppd) は org.freedesktop.UPower.PowerProfiles の D-Bus
# インターフェースを提供し、power-saver / balanced / performance を切り替える。
# 切り替えは `powerprofilesctl set <profile>` または DE の applet から。
#
# TLP は採用しない。tlp 1.10 の tlp-pd も ppd と同一 D-Bus IF を提供するため
# 併用すると競合する。バッテリー充電閾値が必要になった時点で再検討。
{
  pkgs,
  ...
}:

{
  environment.systemPackages = [ pkgs.power-profiles-daemon ];

  # ppd 同梱のユニットを /etc/systemd/system/ に配置する。
  # systemd.packages は $package/lib/systemd/system/* を symlink する。
  #
  # ppd 0.30 が同梱するのは power-profiles-daemon.service のみ。
  # socket ユニットは同梱されないので定義しないこと
  # (systemd.services に "power-profiles-daemon.socket" と書くと
  #  system-manager が "power-profiles-daemon.socket.service" という
  #  実在しないユニットを生成してしまう)。
  systemd.packages = [ pkgs.power-profiles-daemon ];

  # packages 経由のユニットは [Install] WantedBy が効かないため、
  # .wants シンボリックリンクを wantedBy で明示的に作る。
  # 同梱ユニットの [Install] WantedBy=graphical.target に合わせている。
  systemd.services.power-profiles-daemon = {
    wantedBy = [ "graphical.target" ];
  };

  # ppd のユニットは `Conflicts=tuned.service tlp.service auto-cpufreq.service
  # system76-power.service` を宣言している。同じ電源管理役割を持つデーモンを
  # 同時に起動すると片方が恒久的に失敗する。
  #
  # Fedora は tuned、openSUSE は powerdevil 系が既定で入るので、ここを
  # mask しないとディストリによって ppd が起動できない。
  # maskedUnits は /dev/null への symlink を作るだけなので、
  # 元から存在しないユニットを mask しても害はない。
  systemd.maskedUnits = [
    "auto-cpufreq.service"
    "system76-power.service"
    "tuned.service"
    "tlp.service"
  ];

  # 既定 profile は balanced (ppd の upstream デフォルト)。
  # AC 接続時に performance へ自動切り替えたい場合は
  # systemd.user.services + powerprofilesctl を home-manager 側に追加すること。
  # system-manager には udev 相当のオプションが無い (import される NixOS
  # モジュールに services/networking/udev.nix が含まれない) ため、
  # udev ルールによる切替は扱わない。
}
