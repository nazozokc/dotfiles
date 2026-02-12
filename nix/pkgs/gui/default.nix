{ pkgs }:

let
  terminal = import ./terminal.nix { inherit pkgs; };
  editor   = import ./editor.nix   { inherit pkgs; };
  misc     = import ./misc.nix     { inherit pkgs; };
in
  terminal ++ editor ++ misc

