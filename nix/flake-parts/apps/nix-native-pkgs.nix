{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
  linuxPkg = inputs.linux-pkgmanager-nix;
  backends = import "${linuxPkg}/nix/lib/backends.nix";
  declaredCheck = import "${linuxPkg}/nix/lib/declared.nix" { inherit lib backends; };
  inherit (declaredCheck) validate;
  mkNlp = import "${linuxPkg}/nix/lib/mk-nlp.nix" { inherit lib backends validate; };

  pms = lib.attrNames backends;
in
{
  perSystem =
    { pkgs, system, ... }:
    let
      declared =
        validate (
          lib.genAttrs pms (pm:
            let
              path = ../../native-pkgs/${pm}.nix;
            in
            if builtins.pathExists path then import path else [ ]
          )
        );

      nlpDrv = mkNlp { inherit pkgs declared; };
      built = import "${linuxPkg}/nix/lib/apps.nix" {
        inherit lib pkgs;
        nlp = nlpDrv;
        appPrefix = "nlp-";
        defaultApp = null;
      };
    in
    {
      apps = built.apps;
      packages.nlp = built.package;
    };
}
