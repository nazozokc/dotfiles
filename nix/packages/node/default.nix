{ pkgs }:

let
  node = pkgs.nodejs_20;

  nodePkgs = pkgs.nodePackages;

in
{
  # Node 本体
  inherit node;

  # よく使うCLI
  pnpm = nodePkgs.pnpm;
  typescript = nodePkgs.typescript;
  eslint = nodePkgs.eslint;
  prettier = nodePkgs.prettier;

  # 必要ならここに追加していく
}
