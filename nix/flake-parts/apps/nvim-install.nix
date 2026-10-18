# nix/flake-parts/apps/nvim-install.nix
# nvim/nvim-plug-manage/flake.nix へ新しく足した input を解決して flake.lock へ書き込む。
#
# 既存 input のバージョンは bump しない (`nix flake update` との違いはここ)。
# 追加したいプラグインを flake.nix に足したらこれを回してから switch する。
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
      apps.nvim-install = {
        type = "app";
        meta.description = "nvim/nvim-plug-manage/flake.nix に足したプラグインだけ lock する";
        program = "${pkgs.writeShellScriptBin "nvim-install" ''
          set -eo pipefail
          ${c.shell.nixFeatureGuard}
          ${t.printInfo "nvim-install"}
          cd "$(${pkgs.git}/bin/git rev-parse --show-toplevel)"
          ${c.ghAccessToken pkgs}
          cd ${c.nvimPlugDir}
          ${pkgs.nix}/bin/nix flake lock
          cd - > /dev/null
          echo "  nvim/nvim-plug-manage/flake.lock を解決しました"
          echo "  反映するには: nix run .#switch"
        ''}/bin/nvim-install";
      };
    };
}
