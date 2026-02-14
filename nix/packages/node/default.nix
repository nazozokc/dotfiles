{ pkgs, lib ? pkgs.lib }:

let
  inherit (pkgs) buildNpmPackage fetchzip;

  mkNpmPackage = { pname, version, hash, npmDepsHash, description, homepage, mainProgram ? pname, license ? lib.licenses.mit, postInstall ? "" }:
    buildNpmPackage rec {
      inherit pname version hash npmDepsHash mainProgram postInstall;

      src = fetchzip {
        url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
        inherit hash;
      };

      postPatch = ''
        mkdir -p node_modules
      '';

      dontNpmBuild = true;

      meta = {
        inherit description homepage license mainProgram;
      };
    };
in
{
  nodejs = pkgs.nodejs-20_x;

  # mkNpmPackage ブロックで管理するパッケージ群
  npm = mkNpmPackage {
    pname = "npm";
    version = "11.10.0";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    description = "Node package manager";
    homepage = "https://www.npmjs.com/";
    mainProgram = "npm";
  };

  npx = mkNpmPackage {
    pname = "npx";
    version = "10.2.2";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    description = "npm package runner";
    homepage = "https://www.npmjs.com/package/npx";
    mainProgram = "npx";
  };

  pnpm = mkNpmPackage {
    pname = "pnpm";
    version = "10.29.3";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    description = "Fast, disk space efficient package manager";
    homepage = "https://pnpm.io/";
  };
}

