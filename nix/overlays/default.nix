# nix/overlays/default.nix
final: prev:

let
  overlayFiles = [
    ./ai-tools.nix
    ./nix-index.nix
    ./node-packages.nix
    ./gh-pr-review.nix
  ];
in
prev.lib.composeManyExtensions (map (file: import file) overlayFiles) final prev
