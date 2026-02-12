{ pkgs, lib, ... }:

{
  ########################################
  # Linux 専用 Home Manager 設定
  ########################################

  # Linux でだけ入れたいパッケージ
  home.packages = with pkgs; [
    xclip
    wl-clipboard
  ];

  ########################################
  # Linux 向け環境変数
  ########################################
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
  };

  ########################################
  # Linux 専用プログラム
  ########################################
  programs.fish.enable = lib.mkDefault true;

  ########################################
  # Linux 判定ガード
  ########################################
  assertions = [
    {
      assertion = pkgs.stdenv.isLinux;
      message = "os/linux.nix is imported on a non-linux system";
    }
  ];
}

