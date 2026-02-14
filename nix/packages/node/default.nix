{ pkgs, lib ? pkgs.lib }:

let
  inherit (pkgs) buildNpmPackage fetchzip;

  mkNpmPackage = {
    pname,
    npmName ? pname,
    version,
    hash,
    npmDepsHash,
    description,
    homepage,
    license ? lib.licenses.mit,
    mainProgram ? pname,
    forceEmptyCache ? false,
    npmFlags ? [],
    env ? {},
    postInstall ? "",
  }:
    buildNpmPackage rec {
      inherit pname version npmDepsHash npmFlags env postInstall;
      inherit forceEmptyCache;

      src = fetchzip {
        url = "https://registry.npmjs.org/${npmName}/-/${pname}-${version}.tgz";
        inherit hash;
      };

      postPatch = ''
        mkdir -p node_modules
        cp ${./${pname}/package-lock.json} package-lock.json || true
      '';

      dontNpmBuild = true;

      meta = {
        inherit description homepage license mainProgram;
      };
    };

in {
  nodejs = pkgs.nodejs;      # Node
  npm    = pkgs.nodePackages.npm;    # npm
  pnpm   = pkgs.nodePackages.pnpm;   # pnpm
  npx    = pkgs.nodePackages.npx;    # npx

  prettier = mkNpmPackage {
    pname = "prettier";
    version = "3.6.2";
    hash = "sha256-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa=";
    npmDepsHash = "sha256-bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb=";
    description = "Prettier code formatter";
    homepage = "https://prettier.io/";
  };

  # 他の npm CLI パッケージも同様に追加可能
}

