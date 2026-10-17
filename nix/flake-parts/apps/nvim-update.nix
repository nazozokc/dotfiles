# nix/flake-parts/apps/nvim-update.nix
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
        meta.description = "lazy-lock.json から nvim/plugins.nix を再生成・更新する";
        program = "${pkgs.writeShellScriptBin "nvim-update" ''
          set -eo pipefail
          ${c.shell.nixFeatureGuard}
          ${t.printInfo "nvim-update"}
          cd "$(${pkgs.git}/bin/git rev-parse --show-toplevel)"
          ${pkgs.deno}/bin/deno run --allow-read --allow-write --no-lock nix/modules/home/programs/nvim/_gen-plugins.ts
          echo "  plugins.nix を更新しました"
          echo "  反映するには: nix run .#switch"
        ''}/bin/nvim-update";
      };
    };
}
