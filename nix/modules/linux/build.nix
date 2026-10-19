# nix/modules/linux/build.nix
# Linux 向け home-manager 設定を生成するヘルパー (mkLinuxHomeConfig)
# x86_64 / aarch64 / NixOS で共通のモジュール構成を使い回す
#
# 引数は 1 つの attrset:
#   system  … "x86_64-linux" / "aarch64-linux"
#   useNixGL … 非 NixOS (Arch 等の genericLinux) は true (既定)。
#              NixOS は false。NixOS では GPU ドライバが /run/opengl-driver で
#              OS 層から配線されるため nixGL wrap は不要・むしろドライバ不一致の原因
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
    # nixGL は使用しない (NixOS) のとき空で渡す。
    # nix/modules/linux/default.nix 側は useNixGL 判定で定義 skip するため
    # この値は参照されない
    nixGLPackages = if useNixGL then nixGL.packages.${system} else [ ];
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
