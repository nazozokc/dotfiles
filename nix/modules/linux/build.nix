# nix/modules/linux/build.nix
# Linux 向け home-manager 設定を生成するヘルパー (mkLinuxHomeConfig)
# x86_64 / aarch64 で共通のモジュール構成を使い回す
{
  self,
  username,
  pkgsFor,
  home-manager,
  nix-index-database,
  sops-nix,
  agent-skills-nix,
  nixGL,
}:
system:
let
  pkgs = pkgsFor system;
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
    inherit pkgs username;
    dotfilesDir = self.outPath;
    nixGLPackages = nixGL.packages.${system};
  };
  modules = commonHomeModules ++ [
    ../home
    (import ../home/tools-read.nix { inherit pkgs; })
    ./default.nix
  ];
}
