# nix/modules/macos/darwin-home.nix
# macOS 固有の home-manager 設定（ユーザーレベル）
{ config, dotfilesDir, pkgs, ... }:

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

    # GPU ラッパーが不要なプラットフォームでは素の wezterm を使う
    wezterm

    # macOS-only tiling window manager
    aerospace
  ];

  # AeroSpace uses ~/.aerospace.toml as its native configuration path.
  # Keep it separate from the shared ~/.config/wezterm link.
  home.file.".aerospace.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/aerospace/aerospace.toml";
}
