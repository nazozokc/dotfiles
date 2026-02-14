{ pkgs, lib ? pkgs.lib }:

let
  inherit (pkgs) buildNpmPackage fetchzip;

  # 共通 mkNpmPackage
  mkNpmPackage = { pname, version, hash, npmDepsHash, description, homepage, mainProgram ? pname, license ? lib.licenses.mit, postInstall ? "" }:
    buildNpmPackage rec {
      inherit pname version hash npmDepsHash mainProgram postInstall;

      src = fetchzip {
        url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
        inherit hash;
      };

      postPatch = ''
        if [ -f ${./${pname}/package-lock.json} ]; then
          cp ${./${pname}/package-lock.json} package-lock.json
        fi
        mkdir -p node_modules
      '';

      dontNpmBuild = true;

      meta = {
        inherit description homepage license mainProgram;
      };
    };
in
{
  # Node.js 本体（Nixpkgs 管理）
  nodejs = pkgs.nodejs-20_x;

  # npm
  npm = mkNpmPackage {
    pname = "npm";
    version = "10.3.0";
    hash = "sha256-qbBK0sCOwLEHllH7logUSAkVnCTKfco7RkUxrjbSFSE=";
    npmDepsHash = "sha256-yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy=";
    description = "Node package manager";
    homepage = "https://www.npmjs.com/";
    mainProgram = "npm";
  };

  # npx
  npx = mkNpmPackage {
    pname = "npx";
    version = "10.3.0";
    hash = "sha256-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa=";
    npmDepsHash = "sha256-bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb=";
    description = "npm package runner";
    homepage = "https://www.npmjs.com/package/npx";
    mainProgram = "npx";
  };

  # pnpm
  pnpm = mkNpmPackage {
    pname = "pnpm";
    version = "8.10.0";
    hash = "sha256-ccccccccccccccccccccccccccccccccccccccccccc=";
    npmDepsHash = "sha256-ddddddddddddddddddddddddddddddddddddddddddd=";
    description = "Fast, disk space efficient package manager";
    homepage = "https://pnpm.io/";
  };

  # npm CLI ツール例
  npm-cli-tool = mkNpmPackage {
    pname = "npm-CLI-tool";
    version = "1.2.3";
    hash = "sha256-eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee=";
    npmDepsHash = "sha256-fffffffffffffffffffffffffffffffffffffffffff=";
    description = "Example npm CLI helper";
    homepage = "https://example.com/npm-CLI-tool";
  };

  # pnpm CLI ツール例
  pnpm-cli-tools = mkNpmPackage {
    pname = "pnpm-cli-tools";
    version = "0.5.0";
    hash = "sha256-ggggggggggggggggggggggggggggggggggggggggggg=";
    npmDepsHash = "sha256-hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh=";
    description = "Example pnpm CLI helper";
    homepage = "https://example.com/pnpm-cli-tools";
  };

  # npx CLI ツール例
  npx-cli-tools = mkNpmPackage {
    pname = "npx-cli-tools";
    version = "0.3.1";
    hash = "sha256-iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii=";
    npmDepsHash = "sha256-jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj=";
    description = "Example npx CLI helper";
    homepage = "https://example.com/npx-cli-tools";
  };
}

