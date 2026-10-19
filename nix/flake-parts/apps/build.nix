# nix/flake-parts/apps/build.nix
# apps.build — switch 対象のビルドのみ (適用はしない)
#
#   WSL   … homeConfigurations.<username>-wsl
#   macOS … darwinConfigurations.<name>.system
#   Linux … homeConfigurations.<username>.activationPackage
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
      apps.build = {
        type = "app";
        meta.description = "switch 対象のビルドのみ行う（適用はしない）";
        program = "${pkgs.writeShellScriptBin "build" ''
          set -eo pipefail

          ${c.shell.nixFeatureGuard}

          ${c.shell.detectHelpers}

          # sudo 実行時の demote (HOME が /root になるのを防ぐ)
          demoteToSudoUser "$@"

          require_nixbld

          if is_wsl; then
            echo "  system : WSL (x86_64)"
            echo "  target : .#${t.wslConfigName}"
            echo "  cmd    : build"
            echo ""
            ${pkgs.nix-output-monitor}/bin/nom build .#homeConfigurations.${t.wslConfigName}.activationPackage
          elif is_nixos; then
            echo "  system : ${t.sysLabel} (NixOS)"
            echo "  target : .#homeConfigurations.${t.nixosHomeConfigName}.activationPackage"
            echo "  cmd    : build"
            echo ""
            ${pkgs.nix-output-monitor}/bin/nom build .#homeConfigurations.${t.nixosHomeConfigName}.activationPackage
          else
            echo "  system : ${t.sysLabel}"
            echo "  target : ${t.hmConfig}"
            echo "  cmd    : build"
            echo ""
            ${pkgs.nix-output-monitor}/bin/nom build .#${t.hmConfig}
          fi
        ''}/bin/build";
      };
    };
}
