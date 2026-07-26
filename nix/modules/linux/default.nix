# nix/modules/linux/default.nix
# Linux モジュールのエントリーポイント
# 各責務を packages.nix / programs.nix に分離
{
  config,
  pkgs,
  nixGLPackages,
  dotfilesDir,
  ...
}:

let
  # Wrapped version of wezterm with nixGL so it can find system GPU libraries
  # (libEGL.so etc.) on non-NixOS Linux (Arch Linux).
  wezterm-wrapped = config.lib.nixGL.wrap pkgs.wezterm;
  # ghostty also needs nixGL wrapping for same reason
  ghostty-wrapped = config.lib.nixGL.wrap pkgs.ghostty;
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
  # nixGL-wrapped GUI apps
  # ---------------------------------------------------------------------------
  # On non-NixOS, Nix-packaged GUI apps can't find system GPU libraries
  # (libEGL.so etc.) because their RUNPATH only contains Nix store paths.
  # nixGL bridges the gap. Keep these out of packages/gui/default.nix.
  home.packages = [
    wezterm-wrapped
    ghostty-wrapped
  ];

  home.file = {
    ".config/hypr".source = link "${dotfilesDir}/hypr";
    ".config/waybar".source = link "${dotfilesDir}/waybar";
    ".config/rofi".source = link "${dotfilesDir}/rofi";
    ".config/dunst".source = link "${dotfilesDir}/dunst";
  };
}
