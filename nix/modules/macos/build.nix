# nix/modules/macos/build.nix
# macOS (nix-darwin) 向け設定を生成するヘルパー (mkDarwinConfig)
# Apple Silicon (aarch64) は 26.11 系スタック、Intel (x86_64) は 26.05 系スタックを使い分ける
{
  self,
  username,
  pkgsFor,
  nixpkgs,
  darwin,
  darwin-intel,
  home-manager,
  home-manager-intel,
  sops-nix,
  agent-skills-nix,
}:
{
  system,
  extraHomeModules ? [ ],
}:
let
  isIntel = system == "x86_64-darwin";
  darwin' = if isIntel then darwin-intel else darwin;
  homeManager' = if isIntel then home-manager-intel else home-manager;
  pkgs = pkgsFor system;
in
darwin'.lib.darwinSystem {
  inherit system;
  specialArgs = {
    inherit username;
    dotfilesDir = self.outPath;
  };
  modules = [
    # nix-index-database は上流が x86_64-darwin の DB を提供していないため Intel Mac では無効化
    ../nix-conf.nix
    {
      nix.settings.build-users-group = "nixbld";
    }
    ./default.nix
    homeManager'.darwinModules.home-manager
    {
      # 値の単一ソースは nix/lib/nixpkgs-config.nix (pkgsFor / NixOS 側と共有)
      nixpkgs.config = import ../../lib/nixpkgs-config.nix {
        allowDeprecatedx86_64Darwin = isIntel;
      };
      home-manager = {
        useGlobalPkgs = true;
        extraSpecialArgs = {
          inherit pkgs username;
          dotfilesDir = self.outPath;
        };
        users.${username} = {
          imports = [
            sops-nix.homeManagerModules.sops
            ../../shared.nix
            ./darwin-home.nix
            (import ../home/tools-read.nix { inherit pkgs; })
            ../home
            agent-skills-nix.homeManagerModules.default
          ]
          ++ nixpkgs.lib.optionals isIntel [
            # home-manager release-26.05 は stateVersion 26.11 を受け付けないため 26.05 に固定
            { home.stateVersion = nixpkgs.lib.mkForce "26.05"; }
          ]
          ++ extraHomeModules;
        };
      };
    }
  ];
}
