# nix/flake-parts/apps/nvim-install.nix
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
        meta.description = "lazy-lock.json から nvim/plugins.nix を再生成する";
        program = "${pkgs.writeShellScriptBin "nvim-install" ''
          set -eo pipefail
          ${c.shell.nixFeatureGuard}
          ${t.printInfo "nvim-install"}
          cd "$(${pkgs.git}/bin/git rev-parse --show-toplevel)"
          ${pkgs.deno}/bin/deno run --allow-read --allow-write --no-lock nix/modules/home/programs/nvim/_gen-plugins.ts
          echo "  plugins.nix を更新しました"
          echo "  反映するには: nix run .#switch"
        ''}/bin/nvim-install";
      };
    };
}
