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
  zen-browser,
  ambxst,
}:
system:
let
  pkgs = pkgsFor system;
  # Zen Browser は nixpkgs に無いので外部 flake から取る。
  # zen-browser-flake は x86_64-linux / aarch64-linux のみ提供するため、
  # mkLinuxHomeConfig が受け取るのはこの 2 システムに限られる。
  zenBrowser = zen-browser.packages.${system}.zen-browser;
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
    inherit pkgs username zenBrowser;
    dotfilesDir = self.outPath;
    nixGLPackages = nixGL.packages.${system};
    # Ambxst のビルド済みパッケージ (nixosModules は使わない / 理由は flake.nix 参照)
    ambxstPackages = ambxst.packages.${system};
  };
  modules = commonHomeModules ++ [
    ../nix-conf.nix
    ../home
    (import ../home/tools-read.nix { inherit pkgs; })
    ./default.nix
  ];
}
