{ pkgs, lib ? pkgs.lib }:

let
  inherit (pkgs) buildNpmPackage fetchzip;

  # npm CLI パッケージを Nix で管理するためのヘルパー
  mkNpmPackage = { pname, npmName ? pname, version, hash, npmDepsHash, description, homepage, license ? lib.licenses.mit, mainProgram ? pname }: 
    buildNpmPackage rec {
      inherit pname version npmDepsHash;
      src = fetchzip {
        url = "https://registry.npmjs.org/${npmName}/-/${pname}-${version}.tgz";
        inherit hash;
      };
      dontNpmBuild = true;

      meta = {
        inherit description homepage license mainProgram;
      };
    };
in
{
  # 例：UnoCSS Language Server
  unocss-language-server = mkNpmPackage {
    pname = "unocss-language-server";
    version = "0.1.8";
    hash = "sha256-jHFuTpcf4dk8i7Ty1HS9A8OOLarct3w/jovE6/KZHDs=";
    npmDepsHash = "sha256-hqo+J1o4sG+jGQBSGwQ1uvSCS9mCFX6TfjEC9kut9fI=";
    description = "UnoCSS Language Server";
    homepage = "https://github.com/unocss/unocss";
    mainProgram = "unocss-language-server";
  };

  # 例：Prettier
  prettier = mkNpmPackage {
    pname = "prettier";
    version = "3.5.0";
    hash = "sha256-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa=";
    npmDepsHash = "sha256-bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb=";
    description = "Prettier code formatter";
    homepage = "https://prettier.io/";
  };
}

