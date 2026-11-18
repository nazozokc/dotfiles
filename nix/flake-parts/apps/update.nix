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
          # flake update はビルドしない。nom はライブ表示の価値が無く、
          # 非 TTY では Downloads テーブルが壊れるだけなので使わない。
          nix flake update
        ''}/bin/update";
      };
    };
}
