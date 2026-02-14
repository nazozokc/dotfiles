# npmパッケージ自動更新フロー 完全版指示書

---

## 目的

* Nix で管理している npm パッケージを自動で最新バージョンに更新
* 更新対象は `default.nix` 内の `mkNpmPackage` 定義
* 更新項目：

  * `version`
  * `hash`（tarball）
  * `npmDepsHash`（依存関係）

---

## 1. 前提条件

* Nix が使える環境
* npm コマンドが使用可能
* ディレクトリ構造は以下を想定

```
project/
 ├─ default.nix   ← npm パッケージ定義
 └─ update.sh     ← 自動更新スクリプト
```

* node-env 等の補助ファイルは不要

---

## 2. default.nix 作成手順

### 2.1 構造

1. `buildNpmPackage` と `fetchurl` を使用
2. パッケージごとに `mkNpmPackage` ブロックを作成
3. 各ブロックに以下を定義

* `pname` … パッケージ名
* `version` … 初期バージョン
* `hash` … tarball hash（初回はダミーでOK）
* `npmDepsHash` … 初回は空文字
* `description` … 説明
* `homepage` … URL
* `mainProgram` … 実行コマンド名（省略可）
* `license` … ライセンス（省略時は MIT）

### 2.2 例（最小構成）

```nix
{ pkgs, lib ? pkgs.lib }:

let
  inherit (pkgs) buildNpmPackage fetchurl;

  mkNpmPackage = { pname
                 , version
                 , hash
                 , npmDepsHash
                 , description
                 , homepage
                 , mainProgram ? pname
                 , license ? lib.licenses.mit }:
    buildNpmPackage rec {
      inherit pname version hash npmDepsHash mainProgram;

      src = fetchurl {
        url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
        inherit hash;
      };

      dontNpmBuild = true;

      meta = {
        inherit description homepage license mainProgram;
      };
    };
in
{
  nodejs = pkgs.nodejs-20_x;

  npm = mkNpmPackage {
    pname       = "npm";
    version     = "11.10.0";
    hash        = "0000000000000000000000000000000000000000000000000000";
    npmDepsHash = "";
    description = "Node package manager";
    homepage    = "https://www.npmjs.com/";
    mainProgram = "npm";
  };

  pnpm = mkNpmPackage {
    pname       = "pnpm";
    version     = "10.29.3";
    hash        = "0000000000000000000000000000000000000000000000000000";
    npmDepsHash = "";
    description = "Fast, disk-space efficient package manager";
    homepage    = "https://pnpm.io/";
  };
}
```

> ※ hash は初回はダミーで OK、update.sh 実行時に自動で更新される

---

## 3. update.sh 作成手順

### 3.1 基本構造

1. Bash で `set -euo pipefail` を設定
2. カレントディレクトリをスクリプトディレクトリに変更
3. `default.nix` からパッケージリストを抽出
4. npm で最新バージョンを取得
5. `nix-prefetch-url` で tarball hash を取得 → SRI 形式に変換
6. Perl で `default.nix` の `version` と `hash` を更新
7. `nix build` で `npmDepsHash` を算出 → Perl で更新
8. ログを出力

### 3.2 ファイル構成

```
update.sh
default.nix
```

### 3.3 実行方法

```bash
chmod +x update.sh
./update.sh
```

* 実行後、default.nix の version/hash/npmDepsHash が最新化される

---

## 4. update.sh 主要処理の擬似フロー

1. `get_npm_packages` で `pname` と `npmName` を抽出
2. 各パッケージについて `update_npm_package` を実行

   * 現在のバージョン取得
   * 最新バージョン取得
   * バージョンが変わっていたら書き換え
   * tarball hash 更新
   * npmDepsHash 更新
3. 処理完了メッセージ表示


