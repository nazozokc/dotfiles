{
  description = "nazozokc nix + home-manager config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      # nix profile 用（今まで通り）
      packages.${system} = {
        apps = pkgs.callPackage ./pkgs/apps.nix {};
        dev  = pkgs.callPackage ./pkgs/dev.nix {};
        lsp  = pkgs.callPackage ./pkgs/lsp.nix {};

        default = pkgs.buildEnv {
          name = "default";
          paths = [
            self.packages.${system}.apps
            self.packages.${system}.dev
            self.packages.${system}.lsp
          ];
          ignoreCollisions = true;
        };
      };

      # home-manager
      homeConfigurations.nazozokc =
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home/default.nix
          ];
        };
    };
}

