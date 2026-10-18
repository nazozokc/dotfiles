# nix/flake-parts/apps/nvim-install.nix
# nvim/lua/plugins/*.lua の宣言を nvim-plug-manage/flake.nix の inputs へ自動同期し、
# flake.lock へ書き込む。
#
# 既存 input のバージョンは bump しない (`nix flake update` との違いはここ)。
# プラグインを Lua に足したらこれを回してから switch する。
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
        meta.description = "lua/plugins の宣言を nvim-plug-manage へ同期して lock する";
        program = "${pkgs.writeShellScriptBin "nvim-install" ''
          set -eo pipefail
          ${c.shell.nixFeatureGuard}
          ${t.printInfo "nvim-install"}
          cd "$(${pkgs.git}/bin/git rev-parse --show-toplevel)"
          ${c.ghAccessToken pkgs}
          cd ${c.nvimPlugDir}
          ${pkgs.neovim-unwrapped}/bin/nvim -l sync-inputs.lua
          ${pkgs.nix}/bin/nix flake lock
          cd - > /dev/null
          echo "  nvim/nvim-plug-manage/flake.nix を同期して flake.lock を解決しました"
          echo "  反映するには: nix run .#switch"
        ''}/bin/nvim-install";
      };
    };
}
