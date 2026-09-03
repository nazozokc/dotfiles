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
system:
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
    {
      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        build-users-group = "nixbld";
      };
    }
    ./default.nix
    homeManager'.darwinModules.home-manager
    {
      nixpkgs.config.allowUnfree = true;
      # 26.05 で x86_64-darwin の非推奨警告を抑止 (26.11 ではキー自体が不要)
      nixpkgs.config.allowDeprecatedx86_64Darwin = isIntel;
      nixpkgs.config.permittedInsecurePackages = [
        "pnpm-9.15.9"
        "pnpm-10.34.0"
        "electron-39.8.10"
      ];
      nixpkgs.config.problems = {
        handlers.dlinfo.broken = "warn";
      };
      home-manager.useGlobalPkgs = true;
      home-manager.extraSpecialArgs = {
        inherit pkgs username;
        dotfilesDir = self.outPath;
      };
      home-manager.users.${username} = {
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
        ];
      };
    }
  ];
}
