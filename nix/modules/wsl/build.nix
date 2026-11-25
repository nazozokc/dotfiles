# nix/modules/wsl/build.nix
# WSL 向け home-manager 設定を生成するヘルパー (mkWSLHomeConfig)
{
  self,
  username,
  pkgsFor,
  home-manager,
  nix-index-database,
  sops-nix,
  agent-skills-nix,
  orca-nix,
}:
{
  system,
  extraModules ? [ ],
}:
let
  pkgs = pkgsFor system;
  # WSL は GUI を使わないため CLI のみ (orca-cli)。
  orcaPackages = orca-nix.packages.${system};
  commonHomeModules = [
    nix-index-database.homeModules.nix-index
    sops-nix.homeManagerModules.sops
    ../../shared.nix
    agent-skills-nix.homeManagerModules.default
  ];
in
home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = {
    inherit pkgs username orcaPackages;
    dotfilesDir = self.outPath;
  };
  modules =
    commonHomeModules
    ++ [
      ../nix-conf.nix
      ../home/wsl.nix
      (import ./tools-read.nix { inherit pkgs; })
      ./default.nix
    ]
    ++ extraModules;
}
