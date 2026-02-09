{ pkgs }:

pkgs.buildEnv {
  name = "apps";
  paths = import ../pkgs/apps/packages.nix { inherit pkgs; };
  ignoreCollisions = true;
}

