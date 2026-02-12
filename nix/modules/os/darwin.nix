{ pkgs, lib, ... }:

{
  ########################################
  # macOS 専用 Home Manager 設定
  ########################################

  # macOS でだけ入れたいパッケージ
  home.packages = with pkgs; [
    coreutils
    gnugrep
    gnutar
  ];

  ########################################
  # macOS 向け PATH / 環境変数
  ########################################
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
  };

  ########################################
  # macOS 専用プログラム設定
  ########################################
  programs.zsh.enable = lib.mkDefault false;
  programs.fish.enable = lib.mkDefault true;

  ########################################
  # Darwin 判定ガード（安全装置）
  ########################################
  assertions = [
    {
      assertion = pkgs.stdenv.isDarwin;
      message = "os/darwin.nix is imported on a non-darwin system";
    }
  ];
}

