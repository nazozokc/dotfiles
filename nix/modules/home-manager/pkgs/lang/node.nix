{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nodejs_20
    pnpm
    yarn
  ];
}

