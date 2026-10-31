# nix/modules/linux/packages.nix
# Linux 固有のパッケージ
#
# ネイティブ Linux と WSL で共通するパッケージは
# nix/lib/packages/shared.nix が単一ソースで持つ。
# ここに書くのは「ネイティブ Linux だけ」の分だけ。
# 全環境で入る CLI (jq など) は nix/modules/home/packages/base/ が
# 持つので、ここには重複して書かない。
{ pkgs, ... }:

{
  home.packages =
    (import ../../lib/packages/shared.nix { inherit pkgs; })
    ++ (with pkgs; [
      # 音・動画
      alsa-utils
      pulseaudio
      sox

      # ネットワーク (nmap は共通)
      ethtool
      mtr

      # システム監視
      duf # ディスク使用量 (modern df)
      hyperfine # ベンチマーク
      iotop
      lm_sensors
      procs # プロセス表示 (modern ps)
      sd # テキスト置換 (modern sed)
      sysstat
      bandwhich # ネットワーク使用量

      # フォント (fontconfig は共通)
      nerd-fonts.jetbrains-mono

      # セキュリティ/認証 (gnupg / openssh は共通)
      pass
      # Ambxst は polkit agent を同梱しないので polkit_gnome は残す
      polkit_gnome

      # microsoft
      teams-for-linux
    ]);
}
