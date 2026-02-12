{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gcc
    gdb
    clang
    lldb
    cmake
    pkg-config
  ];
}

