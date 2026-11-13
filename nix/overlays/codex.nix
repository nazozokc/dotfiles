# nix/overlays/codex.nix
#
# Workaround for codex build failure on nixpkgs-unstable.
#
# Error:
#   AWS_LC_SYS_USE_SYSTEM=1 requires a system-installed AWS-LC, but none was found.
#
# Cause:
#   cargoSetupHook (nixpkgs#537108) sets AWS_LC_SYS_USE_SYSTEM=1 via the
#   cargoUseSystemLibs preConfigureHook. Detection then fails because it finds
#   OpenSSL (missing AWS-LC's base.h) instead of the aws-lc package.
#
# Fix:
#   Set dontCargoUseSystemLibs to skip the hook entirely. This is the intended
#   opt-out mechanism in cargo-setup-hook.sh.
_final: prev: {
  codex = prev.codex.overrideAttrs (_old: {
    dontCargoUseSystemLibs = true;
  });
}
