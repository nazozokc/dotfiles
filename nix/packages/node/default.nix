{ pkgs, lib ? pkgs.lib }:

let
  inherit (pkgs) buildNpmPackage fetchzip;

  mkNpmPackage = { pname, npmName ? pname, version, hash, npmDepsHash, description, homepage, license ? lib.licenses.mit, mainProgram ? pname }:
    buildNpmPackage rec {
      inherit pname version hash npmDepsHash mainProgram description homepage license;
      src = fetchzip {
        url = "https://registry.npmjs.org/${npmName}/-/${pname}-${version}.tgz";
        inherit hash;
      };
      dontNpmBuild = true;
    };
in
{
  nodejs = pkgs.nodejs-20_x;
  npm = pkgs.nodePackages.npm;
  pnpm = pkgs.nodePackages.pnpm;
  npx = pkgs.nodePackages.npx;

  prettier = mkNpmPackage {
    pname = "prettier";
    version = "3.8.1";
    hash = "sha256-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa=";
    npmDepsHash = "sha256-bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb=";
    description = "Prettier code formatter";
    homepage = "https://prettier.io/";
    mainProgram = "prettier";
  };
}

