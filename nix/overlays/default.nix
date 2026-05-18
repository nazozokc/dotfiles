# nix/overlays/default.nix
final: prev:
prev.lib.composeManyExtensions [
  (import ./ai-tools.nix)
  (import ./node-packages.nix)
] final prev
