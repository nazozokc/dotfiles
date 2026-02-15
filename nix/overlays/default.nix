final: prev:

let
  overlayFiles = [
    ./ai-tools.nix
    ./github-cli.nix
  ];
in
prev.lib.composeManyExtensions
  (map (file: import file) overlayFiles)
  final
  prev

