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
  unocss-language-server = mkNpmPackage {
    pname = "unocss-language-server";
    version = "0.1.8";
    hash = "sha256-jHFuTpcf4dk8i7Ty1HS9A8OOLarct3w/jovE6/KZHDs=";
    npmDepsHash = "sha256-hqo+J1o4sG+jGQBSGwQ1uvSCS9mCFX6TfjEC9kut9fI=";
    description = "UnoCSS Language Server";
    homepage = "https://github.com/unocss/unocss";
  };
}

