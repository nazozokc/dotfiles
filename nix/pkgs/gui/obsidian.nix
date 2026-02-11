{ pkgs, ... }:

let
  nixGLIntel =
    pkgs.nixgl.override {
      enableIntel = true;
      enableNvidia = false;
      enableAmd = false;
    };
in
{
  home.packages = [
    pkgs.obsidian
    nixGLIntel
  ];

  home.file.".local/bin/obsidian".text = ''
    #!/usr/bin/env bash
    exec ${nixGLIntel}/bin/nixGLIntel ${pkgs.obsidian}/bin/obsidian "$@"
  '';

  home.file.".local/bin/obsidian".executable = true;
}

