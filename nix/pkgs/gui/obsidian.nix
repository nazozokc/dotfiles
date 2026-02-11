{ pkgs, ... }:

{
  home.packages = [
    pkgs.obsidian
  ];

  # nixGL を使って Electron(GPU) を正しく動かす
  programs.nixGL = {
    enable = true;
    defaultWrapper = "intel";
  };

  # obsidian を nixGL 経由で起動するラッパー
  home.file.".local/bin/obsidian".text = ''
    #!/usr/bin/env bash
    exec nixGLIntel ${pkgs.obsidian}/bin/obsidian "$@"
  '';

  home.file.".local/bin/obsidian".executable = true;
}

