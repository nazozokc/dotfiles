# nix/modules/linux/default.nix
# Linux モジュールのエントリーポイント
# 各責務を packages.nix / programs.nix に分離
#
# useNixGL … 非 NixOS (Arch 等の genericLinux) は true。NixOS は false。
#   nixGL wrap と targets.genericLinux は NixOS では不要
#   (GPU ドライバは /run/opengl-driver で OS 層から配線される)
{
  config,
  pkgs,
  lib,
  nixGLPackages,
  zenBrowser,
  ambxstPackages,
  dotfilesDir,
  useNixGL ? true,
  ...
}:

let
  # Wrapped version of wezterm with nixGL so it can find system GPU libraries
  # (libEGL.so etc.) on non-NixOS Linux (Arch Linux).
  # NixOS では wrap せず素のパッケージを使う。
  wrap = if useNixGL then config.lib.nixGL.wrap else (pkg: pkg);
  wezterm-app = wrap pkgs.wezterm;
  # ghostty also needs nixGL wrapping for same reason
  ghostty-app = wrap pkgs.ghostty;
  # Zen Browser (Firefox ベース) も GPU アクセラレーションに nixGL が必要
  # (非 NixOS のみ。NixOS では素のパッケージ)
  zen-browser-app = wrap zenBrowser;
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
  # NixOS では targets.genericLinux を有効化しない (home-manager が警告する)。
  # nixGL.packages は attrset 型なので、無効時は丸ごと未定義にする (mkIf)
  targets.genericLinux = lib.mkIf useNixGL {
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
    wezterm-app
    ghostty-app
    zen-browser-app
    ambxstPackages.default
  ];

  # Ambxst が bar / launcher / notifications / 壁紙の layer surface を
  # 自前で持つため、waybar / rofi / dunst の設定リンクは不要。
  # Ambxst 自身の layer rule は生成された hyprland.lua 経由で入る。
  home.file = {
    ".config/hypr".source = link "${dotfilesDir}/hypr";
  };
}
