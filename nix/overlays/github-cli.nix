final: prev:

let
  ghGraphPkg  = gh-graph.packages.${final.system}.default;
  ghNippouPkg = gh-nippou.packages.${final.system}.default;
in
{
  gh-graph  = ghGraphPkg;
  gh-nippou = ghNippouPkg;
}


