# nix/overlays/default.nix
final: prev:
prev.lib.composeManyExtensions [
  ./ai-tools.nix
  ./node-packages.nix
] final prev
