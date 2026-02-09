{ pkgs }:

pkgs.buildEnv {
  name = "dev";
  paths =
    (import ../pkgs/dev/base.nix   { inherit pkgs; }) ++
    (import ../pkgs/dev/node.nix   { inherit pkgs; }) ++
    (import ../pkgs/dev/python.nix { inherit pkgs; }) ++
    (import ../pkgs/dev/rust.nix   { inherit pkgs; });
  ignoreCollisions = true;
}

