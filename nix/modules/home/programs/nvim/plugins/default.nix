# nix/modules/home/programs/nvim/plugins/default.nix
# Neovim プラグインの実体を Nix で持つ（lazy-lock.json を正本）
{ pkgs }:
let
  inherit (pkgs) lib;

  pluginsList = import ../plugins.nix { inherit pkgs lib; };

  entries = map (p: {
    name = builtins.baseNameOf p.outPath;
    value = p;
  }) pluginsList;

  # lazy.nvim の dev.path で使う farm: <farm>/<plugin-name>
  farm = pkgs.runCommand "nvim-lazy-plugins" { } ''
    mkdir -p "$out"
    ${lib.concatMapStrings (e: ''
      ln -s ${e.value} "$out/${lib.escapeShellArg e.name}"
    '') entries}
  '';
in
{
  inherit farm;
  path = "${farm}";
  names = map (e: e.name) entries;
  count = builtins.length entries;
}
