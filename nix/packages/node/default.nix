{ pkgs, lib ? pkgs.lib }:

let
  inherit (pkgs) buildNpmPackage fetchzip;

  # Helper for npm CLI packages from registry
  mkNpmPackage =
    {
      pname,
      npmName ? pname,
      version,
      hash,
      npmDepsHash,
      description,
      homepage,
      license ? lib.licenses.mit,
      mainProgram ? pname,
    }:
    buildNpmPackage rec {
      inherit pname version npmDepsHash;
      src = fetchzip {
        url = "https://registry.npmjs.org/${npmName}/-/${pname}-${version}.tgz";
        inherit hash;
      };

      dontNpmBuild = true;

      postPatch = ''
        mkdir -p node_modules
      '';

      meta = {
        inherit description homepage license mainProgram;
      };
    };
in
{
  # Node.js itself
  nodejs = pkgs.nodejs-20;

  # npm / pnpm / npx
  npm = pkgs.nodePackages.npm;
  pnpm = pkgs.nodePackages.pnpm;
  npx = pkgs.nodePackages.npx;

  # Example npm CLI packages
  prettier = mkNpmPackage {
    pname = "prettier";
    version = "3.8.1";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    npmDepsHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";
    description = "Prettier code formatter";
    homepage = "https://prettier.io/";
    mainProgram = "prettier";
  };

  unocss-language-server = mkNpmPackage {
    pname = "unocss-language-server";
    version = "0.1.8";
    hash = "sha256-CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=";
    npmDepsHash = "sha256-DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD=";
    description = "UnoCSS Language Server";
    homepage = "https://github.com/unocss/unocss";
    mainProgram = "unocss-language-server";
  };
}

