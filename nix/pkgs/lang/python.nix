{ pkgs }:

with pkgs; [
  python312
  python312Packages.pip
  python312Packages.virtualenv
  python312Packages.black
  python312Packages.ruff
  python312Packages.pyright
]

