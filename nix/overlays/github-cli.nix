# nix/overlays/github-cli.nix
#
# GitHub CLI extensions overlay
#
# Usage:
# overlays = [
#   (import ./nix/overlays/github-cli.nix { 
#     inherit gh-graph gh-nippou;
#   })
# ];

{ gh-graph, gh-nippou }:

final: prev:

{
  ########################################
  # GitHub CLI Extensions
  ########################################

  gh-graph = gh-graph.packages.${final.system}.default;

  gh-nippou = gh-nippou.packages.${final.system}.default;

  # ここに将来追加できる
  # gh-something = gh-something.packages.${final.system}.default;
}

