{ pkgs, lib, ... }:

{
  ########################################
  # Linux 専用パッケージ
  ########################################
  home.packages = with pkgs; [
    # 基本
    xclip
    wl-clipboard

    # 音・動画
    pulseaudio
    pavucontrol

    # アーカイブ
    unzip
    zip

    # ネットワーク
    nmap
  ];

  ########################################
  # Linux 専用プログラム有効化
  ########################################
  programs.fish.enable = true;
}
