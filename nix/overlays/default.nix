# nix/overlays/default.nix
{ self }:
final: prev:
prev.lib.composeManyExtensions [
  (import ./ai-tools.nix)
  (import ./bitwarden-cli.nix)
  (import ./compiler-rt.nix)
  (import ./node-packages.nix)
  (import ./python-packages.nix)
  (import ./rust-packages.nix)
  (import ./fish-plugins.nix)
  (import ./typescript.nix)
  (import ./my-scripts.nix { inherit self; })
] final prev
