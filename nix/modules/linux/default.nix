# nix/modules/linux/default.nix
# Linux モジュールのエントリーポイント
# 各責務を packages.nix / programs.nix に分離
{
  config,
  pkgs,
  nixGLPackages,
  zenBrowser,
  ambxstPackages,
  dotfilesDir,
  ...
}:

let
  # Wrapped version of wezterm with nixGL so it can find system GPU libraries
  # (libEGL.so etc.) on non-NixOS Linux (Arch Linux).
  wezterm-wrapped = config.lib.nixGL.wrap pkgs.wezterm;
  # ghostty also needs nixGL wrapping for same reason
  ghostty-wrapped = config.lib.nixGL.wrap pkgs.ghostty;
  # Zen Browser (Firefox ベース) も GPU アクセラレーションに nixGL が必要
  zen-browser-wrapped = config.lib.nixGL.wrap zenBrowser;
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  imports = [
    ./packages.nix
    ./system.nix
    ../home/systemd
  ];

  # ---------------------------------------------------------------------------
  # Generic Linux support – enables XDG paths, nixGL, etc. for non-NixOS distros
  # ---------------------------------------------------------------------------
  targets.genericLinux = {
    enable = true;
    nixGL = {
      packages = nixGLPackages;
      # Provide nixGLMesa script for ad-hoc wrapping of other GPU apps
      installScripts = [ "mesa" ];
    };
  };

  # ---------------------------------------------------------------------------
  # nixGL-wrapped GUI apps + Ambxst
  # ---------------------------------------------------------------------------
  # On non-NixOS, Nix-packaged GUI apps can't find system GPU libraries
  # (libEGL.so etc.) because their RUNPATH only contains Nix store paths.
  # nixGL bridges the gap. Keep these out of packages/gui/default.nix.
  #
  # Ambxst は nixGL wrap 不要: launcher が buildEnv 経由で mesa / libglvnd /
  # egl-wayland を同梱し、PATH 経由で参照する設計のため。
  home.packages = [
    wezterm-wrapped
    ghostty-wrapped
    zen-browser-wrapped
    ambxstPackages.default
  ];

  # Ambxst が bar / launcher / notifications / 壁紙の layer surface を
  # 自前で持つため、waybar / rofi / dunst の設定リンクは不要。
  # Ambxst 自身の layer rule は生成された hyprland.lua 経由で入る。
  home.file = {
    ".config/hypr".source = link "${dotfilesDir}/hypr";
  };
}
