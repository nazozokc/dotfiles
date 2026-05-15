# nix/overlays/default.nix
final: prev:

let
  overlayFiles = [
    ./ai-tools.nix
    ./node-packages.nix
  ];
in
prev.lib.composeManyExtensions (map (file: import file) overlayFiles) final prev
