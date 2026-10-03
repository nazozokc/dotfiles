{
  description = "linux-pkgmanager nix module";

  outputs = { self }: {
    nixosModules.default = import ./default.nix;
  };
}
