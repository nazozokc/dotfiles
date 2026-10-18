# nix/flake-parts/apps/nvim-update.nix
# Neovim プラグインを最新へ一括 bump する。
#
# 実体とバージョンの正本は nvim/nvim-plug-manage/flake.lock。
# ここはその flake.lock を `nix flake update` で更新するだけ。
# rev と narHash が両方動くので、ハッシュの手当ては不要。
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
      apps.nvim-update = {
        type = "app";
        meta.description = "nvim/nvim-plug-manage/flake.lock のプラグインを全部更新する";
        program = "${pkgs.writeShellScriptBin "nvim-update" ''
          set -eo pipefail
          ${c.shell.nixFeatureGuard}
          ${t.printInfo "nvim-update"}
          cd "$(${pkgs.git}/bin/git rev-parse --show-toplevel)"
          ${c.ghAccessToken pkgs}
          cd ${c.nvimPlugDir}
          ${pkgs.nix}/bin/nix flake update
          cd - > /dev/null
          echo "  nvim/nvim-plug-manage/flake.lock を更新しました"
          echo "  反映するには: nix run .#switch"
        ''}/bin/nvim-update";
      };
    };
}
