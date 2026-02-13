# Nix コード修正指示書（エラー箇所のみ）

## 目的

既存 Flake で発生する以下のエラーを修正すること：

* `attribute 'apps.x86_64-linux.switch' should have type 'app'`
* `'apps.x86_64-linux.switch.program' is not a string but a set`

内容・機能は一切変更せず、**型エラー・構文エラーのみ修正**する。

---

## 指示 1: apps に関する型エラー修正

### 現状

```nix
apps = {
  "x86_64-linux" = {
    switch = linuxPkgs.runCommand "hm-switch" { ... } '';
      ...
    '';
    ...
  };
};
```

* `runCommand` は derivation を返すため、flake-parts が期待する **`type = "app"` + `program` が文字列** に合わない。

### 修正指示

1. `apps.<system>.<name>` は **必ず type="app" と program=writeShellScriptBin で包む**。
2. `runCommand` の使用をやめ、以下の形に置き換える：

```nix
switch = {
  type = "app";
  program = linuxPkgs.writeShellScriptBin "hm-switch" ''
    set -e
    echo "Building and switching Linux Home Manager config..."
    nix run nixpkgs#home-manager -- switch --flake .#${username}
    echo "Done!"
  '';
};
```

* `update` / `update-node-packages` も同様に `writeShellScriptBin + type="app"` に変更する。

---

## 指示 2: system 別の dotfilesDir 呼び出し修正

### 現状

```nix
${dotfilesDir "x86_64-linux"}/nix/packages/node/update.sh
```

* 文字列の展開により derivation ではなく文字列を期待する箇所に **関数呼び出しの結果がセット** になっている可能性がある。

### 修正指示

1. `dotfilesDir` は文字列を返すように関数を明示：

```nix
dotfilesDir system: "${homeDir system}/ghq/github.com/nazozokc/dotfiles"
```

2. 呼び出し側も文字列として展開：

```nix
${linuxPkgs.bash}/bin/bash ${dotfilesDir "x86_64-linux"}/nix/packages/node/update.sh
```

* Flake 内ではこれで string として解釈されることを確認。

---

## 指示 3: apps 全体の統一形式

### 現状

* Linux は runCommand
* macOS は runCommand
* 両方とも type="app" が設定されていない

### 修正指示

1. Linux/macOS 両方とも **以下の形式で統一**：

```nix
apps = {
  "x86_64-linux" = {
    switch = {
      type = "app";
      program = linuxPkgs.writeShellScriptBin "hm-switch" ''
        ...
      '';
    };
    update = { type="app"; program=...; };
    update-node-packages = { type="app"; program=...; };
  };

  "aarch64-darwin" = {
    switch = { type="app"; program=darwinPkgs.writeShellScriptBin "darwin-switch" '' ... ''; };
    update = { type="app"; program=...; };
    update-node-packages = { type="app"; program=...; };
  };
};
```

---

### 注意点

* **機能は絶対に変えない**：スクリプト内容やフレーク構造はそのまま。
* **修正対象は apps の型・program 部分のみ**。
* `writeShellScriptBin` は文字列として返すので、flake-parts の `app` 型チェックに合致する。

