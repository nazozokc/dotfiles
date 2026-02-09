{ pkgs, self, system }:

pkgs.buildEnv {
  name = "default";
  paths = [
    self.packages.${system}.apps
    self.packages.${system}.dev
    self.packages.${system}.nvim
  ];
  ignoreCollisions = true;
}

