# AI 指示書：Nazozo 用 default.nix + update.sh 自動生成

## 目的

* Node.js 系パッケージを Nix で管理する
* npm パッケージ（例：prettier）も Nix 管理
* バージョン、hash、npmDepsHash を自動更新可能にする

---

## 生成対象ファイル

### 1. `default.nix`

**仕様**

* `pkgs` と `lib` を引数に取る
* Node / npm / pnpm / npx を Nix パッケージとして追加
* npm パッケージは `mkNpmPackage` を使って定義
* 各 npm パッケージに `pname`, `npmName`, `version`, `hash`, `npmDepsHash`, `description`, `homepage` を持たせる

**例フォーマット**

```nix
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
    license ? lib.licenses.mit
  }:
    buildNpmPackage rec {
      inherit pname version npmDepsHash;
      src = fetchzip {
        url = "https://registry.npmjs.org/${npmName}/-/${pname}-${version}.tgz";
        inherit hash;
      };
      dontNpmBuild = true;
      meta = { inherit description homepage license; };
    };
in {
  node = pkgs.nodejs-20;
  npm  = pkgs.nodePackages.npm;
  pnpm = pkgs.nodePackages.pnpm;
  npx  = pkgs.nodePackages.npx;

  prettier = mkNpmPackage {
    pname = "prettier";
    npmName = "prettier";
    version = "3.8.1";
    hash = "sha256-...";
    npmDepsHash = "sha256-...";
    description = "Prettier code formatter";
    homepage = "https://prettier.io/";
  };
}
```

---

### 2. `update.sh`

**仕様**

* `default.nix` を解析して npm パッケージの `pname` と `npmName` を取得
* npm で最新バージョンを取得
* バージョンが変わった場合、`default.nix` の `version` を更新
* 新しい tarball hash (`hash`) を `nix-prefetch-url --unpack` で取得して更新
* `npmDepsHash` を Nix の impure evaluation で計算して更新
* 実行方法: `nix run .#update-node-packages`

**例フォーマット**

```bash
#!/usr/bin/env bash
set -euo pipefail

DEFAULT_NIX="./default.nix"

update_package() {
  local pname="$1"
  local npm_name="$2"

  # 現行バージョン取得
  local current_version
  current_version=$(perl -ne "print \$1 if /pname = \"$pname\".*?version = \"([^\"]+)\"/s" "$DEFAULT_NIX")

  # 最新バージョン取得
  local latest_version
  latest_version=$(npm view "$npm_name" version)

  # バージョン更新
  if [[ "$current_version" != "$latest_version" ]]; then
    perl -0777 -pi -e "s/(pname = \"$pname\".*?version = \")$current_version/\$1$latest_version/s" "$DEFAULT_NIX"
  fi

  # hash 更新
  local url="https://registry.npmjs.org/${npm_name}/-/${pname}-${latest_version}.tgz"
  local new_hash
  new_hash=$(nix-prefetch-url --unpack "$url")
  perl -0777 -pi -e "s/(pname = \"$pname\".*?version = \"$latest_version\".*?hash = \")sha256-[^\"]+/\$1$new_hash/s" "$DEFAULT_NIX"

  # npmDepsHash 更新
  local deps_hash
  deps_hash=$(nix eval --impure --raw "(import $DEFAULT_NIX {}).$pname.npmDepsHash")
  perl -0777 -pi -e "s/(pname = \"$pname\".*?npmDepsHash = \")sha256-[^\"]+/\$1$deps_hash/s" "$DEFAULT_NIX"
}

# npm パッケージ一覧取得
while read -r pname npm_name; do
  update_package "$pname" "$npm_name"
done < <(
  perl -0777 -ne 'while(/mkNpmPackage\s*\{(.*?)\};/gs){ my $b=$1; my ($pname)=$b=~/pname\s*=\s*"([^"]+)"/; my ($npm)=$b=~/npmName\s*=\s*"([^"]+)"/; $npm=$pname unless $npm; print "$pname\t$npm\n";}' "$DEFAULT_NIX"
)
```

---

### 注意点

1. `update.sh` は bash で動作
2. npm パッケージの `pname` または `npmName` が必須
3. npmDepsHash は Nix の impure evaluation を使う
4. URL が空 (`//-/-`) にならないように注意


