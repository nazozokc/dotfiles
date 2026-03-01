final: prev:

let
  overlayFiles = [
    ./ai-tools.nix
    ./nix-index.nix
    ./node-packages.nix
  ];
in
prev.lib.composeManyExtensions
  (map (file: import file) overlayFiles)
  final
  prev
