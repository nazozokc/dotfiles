# minimal-binary-cache.nix
# Official cache.nixos.org only

let
  substituters = [
    "https://cache.nixos.org/"
  ];

  trustedPublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];
in
{
  # Standard Nix configuration
  nix.settings = {
    substituters = substituters;
    trusted-public-keys = trustedPublicKeys;

    # Strictly prevent additional substituters
    require-sigs = true;
  };

  # Flake configuration
  nixConfig = {
    extra-substituters = substituters;
    extra-trusted-public-keys = trustedPublicKeys;
  };
}

