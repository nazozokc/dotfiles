# nix/overlays/default.nix
final: prev:
prev.lib.composeManyExtensions [
  (import ./ai-tools.nix)
  (import ./compiler-rt.nix)
  (import ./node-packages.nix)
  (import ./pipx.nix)
] final prev
