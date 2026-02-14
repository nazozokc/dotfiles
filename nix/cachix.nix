# cachix.nix
# Minimal binary cache configuration (official cache only)

let
  substituters = [
    "https://cache.nixos.org"
  ];

  publicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];
in
{
  inherit substituters publicKeys;

  flakeConfig = {
    extra-substituters = substituters;
    extra-trusted-public-keys = publicKeys;
  };
}

