{
  pkgs,
  lib ? pkgs.lib,
}:

let
  inherit (pkgs) buildNpmPackage fetchurl;

  mkNpmPackage =
    {
      pname,
      version,
      hash,
      npmDepsHash,
      description,
      homepage,
      mainProgram ? pname,
      license ? lib.licenses.mit,
    }:
    buildNpmPackage rec {
      inherit
        pname
        version
        hash
        npmDepsHash
        mainProgram
        ;

      src = fetchurl {
        url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
        inherit hash;
      };

      dontNpmBuild = true;

      meta = {
        inherit
          description
          homepage
          license
          mainProgram
          ;
      };
    };
in
{}
