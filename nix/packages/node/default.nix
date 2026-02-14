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
{
  nodejs = pkgs.nodejs-20_x;

  npm = mkNpmPackage {
    pname = "npm";
    version = "11.10.0";
    hash = "0000000000000000000000000000000000000000000000000000";
    npmDepsHash = "";
    description = "Node package manager";
    homepage = "https://www.npmjs.com/";
    mainProgram = "npm";
  };

  pnpm = mkNpmPackage {
    pname = "pnpm";
    version = "10.29.3";
    hash = "0000000000000000000000000000000000000000000000000000";
    npmDepsHash = "";
    description = "Fast, disk-space efficient package manager";
    homepage = "https://pnpm.io/";
  };
}
