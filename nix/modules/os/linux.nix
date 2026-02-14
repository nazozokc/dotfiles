{ config, pkgs, ... }:

let
  username = config.username or "nazozokc";
in
{
  ########################################
  # OS 固有の設定
  ########################################
  # 例: 基本のタイムゾーン
  time.timeZone = "Asia/Tokyo";

  # 例: 基本ロケール
  i18n = {
    defaultLocale = "ja_JP.UTF-8";
    supportedLocales = [ "ja_JP.UTF-8" "en_US.UTF-8" ];
  };

  ########################################
  # 必要なパッケージ
  ########################################
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    htop
  ];
}
