{ pkgs }:

with pkgs;

let
  core   = import ./core.nix   { inherit pkgs; };
  git    = import ./git.nix    { inherit pkgs; };
  search = import ./search.nix { inherit pkgs; };
  misc   = import ./misc.nix   { inherit pkgs; };
in
  core ++ git ++ search ++ misc

