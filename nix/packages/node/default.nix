{ pkgs, lib ? pkgs.lib }:

let
  inherit (pkgs) buildNpmPackage fetchzip;

  # Helper for npm CLI packages from registry
  mkNpmPackage =
    { pname, version, hash, npmDepsHash, description, homepage, mainProgram ? pname }:
    buildNpmPackage rec {
      inherit pname version hash npmDepsHash mainProgram description homepage;
      src = fetchzip {
        url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
        inherit hash;
      };
      dontNpmBuild = true;
      postPatch = ''
        mkdir -p node_modules
      '';
      meta = { inherit description homepage mainProgram; };
    };
in
{
  # Node 本体とパッケージマネージャ
  nodejs = pkgs.nodejs-20_x;
  npm    = pkgs.nodePackages.npm;
  pnpm   = pkgs.nodePackages.pnpm;
  npx    = pkgs.nodePackages.npx;

  # ここに CLI ツールを追加できる
  prettier = mkNpmPackage {
    pname = "prettier";
    version = "3.5.0";
    hash = "sha256-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa=";
    npmDepsHash = "sha256-bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb=";
    description = "Prettier code formatter";
    homepage = "https://prettier.io";
  };

  eslint = mkNpmPackage {
    pname = "eslint";
    version = "8.46.0";
    hash = "sha256-ccccccccccccccccccccccccccccccccccccccccccc=";
    npmDepsHash = "sha256-ddddddddddddddddddddddddddddddddddddddddddd=";
    description = "ESLint code linter";
    homepage = "https://eslint.org";
  };
}

