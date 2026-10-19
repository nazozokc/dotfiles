# nix/modules/linux/build.nix
# Linux 向け home-manager 設定生成ヘルパー (mkLinuxHomeConfig)
# x86_64 / aarch64 で共通のモジュール構成を使い回す
#
# useNixGL: 非 NixOS Linux (Arch / Ubuntu ...) では true。
#   NixOS では false を渡すこと。NixOS の GPU ドライバは
#   /run/opengl-driver が正しく、nixGL の store ライブラリで
#   上書きするとドライバ不一致で GUI が壊れる。
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
{
  system,
  useNixGL ? true,
}:
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
    inherit
      pkgs
      username
      zenBrowser
      useNixGL
      ;
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
