{ pkgs, lib ? pkgs.lib }:

let
  inherit (pkgs) buildNpmPackage fetchzip;

  mkNpmPackage = { pname, npmName ? pname, version, hash, npmDepsHash, description, homepage, license ? lib.licenses.mit, mainProgram ? pname, forceEmptyCache ? false, npmFlags ? [ ], env ? { }, postInstall ? "" }:
    buildNpmPackage rec {
      inherit pname version npmDepsHash npmFlags env postInstall;
      inherit forceEmptyCache;

      src = fetchzip {
        url = "https://registry.npmjs.org/${npmName}/-/${pname}-${version}.tgz";
        inherit hash;
      };

      postPatch = ''
        cp ${./${pname}/package-lock.json} package-lock.json
        mkdir -p node_modules
      '';

      dontNpmBuild = true;

      meta = {
        inherit description homepage license mainProgram;
      };
    };
in
{
  unocss-language-server = mkNpmPackage {
    pname = "unocss-language-server";
    version = "0.1.8";
    hash = "sha256-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa=";
    npmDepsHash = "sha256-bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb=";
    description = "UnoCSS Language Server";
    homepage = "https://github.com/unocss/unocss";
    mainProgram = "unocss-language-server";
  };

  prettier = mkNpmPackage {
    pname = "prettier";
    version = "3.8.1";
    hash = "sha256-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=";
    npmDepsHash = "sha256-yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy=";
    description = "Prettier code formatter";
    homepage = "https://prettier.io/";
    mainProgram = "prettier";
  };
}

