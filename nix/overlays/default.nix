final: prev:

let
  overlayFiles = [
    ./ai-tools.nix
    ./github-cli.nix
  ];

  overlays =
    map (file: import file) overlayFiles;

in
builtins.foldl'
  (acc: overlay: overlay final acc)
  prev
  overlays
