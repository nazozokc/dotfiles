{ pkgs, lib ? pkgs.lib }:

let
  inherit (pkgs) buildNpmPackage fetchzip;

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
      forceEmptyCache ? false,
      npmFlags ? [],
      env ? {},
      postInstall ? "",
    }:
    buildNpmPackage rec {
      inherit pname version npmDepsHash npmFlags env postInstall forceEmptyCache;

      src = fetchzip {
        url = "https://registry.npmjs.org/${npmName}/-/${pname}-${version}.tgz";
        inherit hash;
      };

      postPatch = ''
        mkdir -p node_modules
        if [ -f ${./${pname}/package-lock.json} ]; then
          cp ${./${pname}/package-lock.json} package-lock.json
        fi
      '';

      dontNpmBuild = true;

      meta = {
        inherit description homepage license mainProgram;
      };
    };
in
{
  node = pkgs.nodejs-20;

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
  };

  # 他の npm CLI パッケージもここに追加できる
}

