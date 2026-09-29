# nix/flake-parts/apps/update.nix
# apps.update — flake.lock の更新
{ inputs, ... }:
let
  c = import ./common.nix { inherit inputs; };
in
{
  perSystem =
    { pkgs, system, ... }:
    let
      t = c.targetsFor system;
    in
    {
      apps.update = {
        type = "app";
        meta.description = "flake.lock を更新する";
        program = "${pkgs.writeShellScriptBin "update" ''
          set -eo pipefail

          ${c.shell.nixFeatureGuard}

          ${t.printInfo "update"}
          nix flake update |& ${pkgs.nix-output-monitor}/bin/nom
        ''}/bin/update";
      };
    };
}
