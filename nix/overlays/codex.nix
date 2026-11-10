# nix/overlays/codex.nix
#
# Workaround for codex build failure on nixpkgs-unstable.
#
# Error:
#   AWS_LC_SYS_USE_SYSTEM=1 requires a system-installed AWS-LC, but none was found.
#
# Cause:
#   Recent cargoSetupHook (nixpkgs#537108) sets AWS_LC_SYS_USE_SYSTEM=1 to prefer
#   system libraries. The detection then fails because it finds OpenSSL (which
#   lacks AWS-LC's base.h) instead of the aws-lc package in buildInputs.
#
# Fix:
#   Unset the force-system flag so aws-lc-sys falls back to building from the
#   bundled source.
final: prev: {
  codex = prev.codex.overrideAttrs (old: {
    env = (old.env or { }) // {
      AWS_LC_SYS_USE_SYSTEM = "0";
    };
  });
}
