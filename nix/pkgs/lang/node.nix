{ pkgs }:

with pkgs; [
  nodejs_20
  nodePackages.npm
  nodePackages.yarn
  nodePackages.pnpm
  nodePackages.typescript
  nodePackages.typescript-language-server
]

