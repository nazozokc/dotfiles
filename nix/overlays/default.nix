# nix/overlays/default.nix

final: prev:
let
  ai   = import ./ai.nix final prev;
  node = import ./node.nix final prev;
  git  = import ./git.nix final prev;
in
  ai
  // node
  // git

