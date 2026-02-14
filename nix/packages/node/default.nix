{ pkgs, lib ? pkgs.lib }:

let
  inherit (pkgs) buildNpmPackage fetchurl;

  mkNpmPackage = { pname
                 , version
                 , hash
                 , npmDepsHash
                 , description
                 , homepage
                 , mainProgram ? pname
                 , license ? lib.licenses.mit }:
    buildNpmPackage rec {
      inherit pname version hash npmDepsHash mainProgram;

      src = fetchurl {
        url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
        inherit hash;
      };

      dontNpmBuild = true;

      meta = {
        inherit description homepage license mainProgram;
      };
    };
in
{
  nodejs = pkgs.nodejs-20_x;

  npm = mkNpmPackage {
    pname        = "npm";
    version      = "11.10.0";
    hash         = "088ms8vawca58qxwlzfa4jf1a2a82j49dysijq3v3h4fq394mc59";
    npmDepsHash  = "";
    description  = "Node package manager";
    homepage     = "https://www.npmjs.com/";
    mainProgram  = "npm";
  };

  npx = mkNpmPackage {
    pname        = "npx";
    version      = "10.2.2";
    hash         = "08y76vn8b1l60mjzg2rlr9h6hcaybdd8xrpx240m1x0zwrd47xwf";
    npmDepsHash  = "";
    description  = "npm package runner";
    homepage     = "https://www.npmjs.com/package/npx";
    mainProgram  = "npx";
  };

  pnpm = mkNpmPackage {
    pname        = "pnpm";
    version      = "10.29.3";
    hash         = "13gfcxy9y3sa7xrql4p0dy57iiryfji1hkz2cmkx4vmjmnrv36lx";
    npmDepsHash  = "";
    description  = "Fast, disk space efficient package manager";
    homepage     = "https://pnpm.io/";
  };
}

