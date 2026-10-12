{ pkgs, ... }:

let
  plugins = [
    "npm:opencode-pi"
  ];
in
{
  home.activation.piPlugins = pkgs.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    installed=$(${pkgs.pi}/bin/pi list 2>/dev/null || true)
    ${pkgs.lib.concatMapStrings (p: ''
      if ! echo "$installed" | grep -qF "${p}"; then
        $DRY_RUN_CMD ${pkgs.pi}/bin/pi install "${p}" 2>&1 | $DRY_RUN_CMD tee >&2
      fi
    '') plugins}
  '';
}
