{
  description = "Arch Linux user environment (apps / dev / nvim) managed by Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    packages.${system} = {
      apps    = import ./profiles/apps.nix    { inherit pkgs; };
      dev     = import ./profiles/dev.nix     { inherit pkgs; };
      nvim    = import ./profiles/nvim.nix    { inherit pkgs; };

      default = import ./profiles/default.nix { inherit pkgs self system; };
    };

    defaultPackage.${system} = self.packages.${system}.default;
  };
}

