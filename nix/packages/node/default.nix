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
  # Node.js 本体
  nodejs = pkgs.nodejs-20_x;

  # npm 本体
  npm = mkNpmPackage {
    pname = "npm";
    .10.0";
    hash = "sha256-qbBK0sCOwLEHllH7logUSAkVnCTKfco7RkUxrjbSFSE=";
    npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    description = "Node package manager";
    homepage = "https://www.npmjs.com/";
    mainProgram = "npm";
  };

  # npx（npm に同梱されるが明示管理）
  npx = mkNpmPackage {
    pname = "npx";
    version = "10.2.2";
    hash = "sha256-jvdDWuYf9FABEf3mjlpbXjFoYMo0i/dlBYaGhew2xyM=";
    npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    description = "npm package runner";
    homepage = "https://www.npmjs.com/package/npx";
    mainProgram = "npx";
  };

  # pnpm 本体
  pnpm = mkNpmPackage {
    pname = "pnpm";
    version = "10.29.3";
    hash = "sha256-nZqxs62ybtJnZeJPGKJ0Psd4im/gEopzP0oPn3xn7o0=";
    npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    description = "Fast, disk space efficient package manager";
    homepage = "https://pnpm.io/";
  };
}

