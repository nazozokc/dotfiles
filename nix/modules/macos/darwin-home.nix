# nix/modules/macos/darwin-home.nix
# macOS 固有の home-manager 設定（ユーザーレベル）
{ pkgs, ... }:

{
  ########################################
  # ロケール設定
  ########################################
  home.sessionVariables = {
    LANG = "ja_JP.UTF-8";
    LC_ALL = "ja_JP.UTF-8";
  };

  ########################################
  # macOS 専用パッケージ（home-manager 管理）
  ########################################
  home.packages = with pkgs; [
    # フォント
    fontconfig
  ];
}
