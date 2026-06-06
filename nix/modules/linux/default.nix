# nix/modules/linux/default.nix
# Linux モジュールのエントリーポイント
# 各責務を packages.nix / programs.nix に分離
{
  config,
  pkgs,
  nixGLPackages,
  ...
}:

let
  # Wrapped version of wezterm with nixGL so it can find system GPU libraries
  # (libEGL.so etc.) on non-NixOS Linux (Arch Linux).
  wezterm-wrapped = config.lib.nixGL.wrap pkgs.wezterm;
in
{
  imports = [
    ./packages.nix
    ./system.nix
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
  # wezterm: nixGL-wrapped version
  # ---------------------------------------------------------------------------
  # On non-NixOS, the Nix-packaged wezterm can't find system libEGL.so because
  # its RUNPATH only contains Nix store paths. nixGL bridges the gap.
  # wezterm は gui/default.nix から外し、Linux でのみ wrapped 版を入れる。
  home.packages = [
    wezterm-wrapped
  ];
}
