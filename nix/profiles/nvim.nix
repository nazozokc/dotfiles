{ pkgs }:

pkgs.buildEnv {
  name = "nvim";
  paths =
    (import ../pkgs/nvim/lsp.nix   { inherit pkgs; }) ++
    (import ../pkgs/nvim/tools.nix { inherit pkgs; });
  ignoreCollisions = true;
}

