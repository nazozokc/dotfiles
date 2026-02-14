{ pkgs, lib ? pkgs.lib }:

let
  inherit (pkgs) buildNpmPackage fetchzip;

  mkNpmPackage =
    { pname, npmName ? pname, version, hash, npmDepsHash, description, homepage, license ? lib.licenses.mit }:
    buildNpmPackage rec {
      inherit pname version npmDepsHash;
      src = fetchzip {
        url = "https://registry.npmjs.org/${npmName}/-/${pname}-${version}.tgz";
        inherit hash;
      };
      dontNpmBuild = true;
      meta = { inherit description homepage license; };
    };
in
{
  node = pkgs.nodejs-20;
  npm = pkgs.nodePackages.npm;
  pnpm = pkgs.nodePackages.pnpm;
  npx = pkgs.nodePackages.npx;

  prettier = mkNpmPackage {
    add4c18afm3ab25zkb48fx1qpl6hg4rg4mssfclh5za00dwcy2c";
    npmDepsHash = "sha256-bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb=";
    description = "Prettier code formatter";
    homepage = "https://prettier.io/";
  };
}

