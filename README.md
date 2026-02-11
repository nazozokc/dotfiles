# nazozo Dotfiles

このリポジトリは **Linux (Arch Linux) / macOS (Darwin)** 両対応の dotfiles 管理 flake です。  
`home-manager` と `nix-darwin` を使って、CLI / GUI アプリ、設定ファイル、シェル環境などを一元管理します。

## 概要

- **パッケージ管理**
  - Linux / macOS 共通で Home Manager による管理
  - CLI ツールと GUI ツールを flake 経由でインストール
- **OS別設定**
  - `linux.nix` / `darwin.nix` で OS 固有の設定を管理
- **設定ファイル管理**
  - `config-sym.nix` で `.config` 配下のシンボリックリンクを自動生成
- **multi-system flake**
  - Linux / macOS どちらの環境でも同じ flake を利用可能
  - `home-manager` と `nix-darwin` を同時にサポート

## ファイル構成

```

dotfiles/
├─ flake.nix
├─ nix/
│  ├─ modules/
│  │  ├─ shared.nix         # 共通設定
│  │  ├─ os/
│  │  │   ├─ linux.nix      # Linux 専用設定
│  │  │   └─ darwin.nix     # macOS 専用設定
│  │  └─ pkgs/
│  │      ├─ cli.nix        # CLI ツール
│  │      └─ gui.nix        # GUI ツール
│  └─ config-sym.nix        # シンボリックリンク管理

````

## 対応アプリ

### CLI

- `xclip`, `wl-clipboard`, `xdg-utils` など (Linux)
- `git`, `nvim`, `fzf`, `htop` など (共通)

### GUI

- `vscode`, `spotify`, `discord`, `firefox`, `google-chrome`, `ghostty`, `wezterm`, `zen-browser`

## セットアップ手順

### Linux

```bash
# flake から home-manager を有効化
home-manager switch --flake .#x86_64-linux
````

### macOS

```bash
# flake から home-manager を有効化
home-manager switch --flake .#aarch64-darwin

# nix-darwin 用にシステム設定
darwin-rebuild switch --flake .#nazozokc
```

## 注意点

* `home-manager` を使って `.config` 配下の設定をリンクするため、既存の設定ファイルは上書きされる場合があります。
* GUI ツールの一部は `unfree` ライセンスのため、flake 内で `config.allowUnfree = true;` を設定しています。
* Linux / macOS 共通で動作しますが、OS 固有のパッケージは `linux.nix` / `darwin.nix` で管理してください。

## 更新

```bash
# flake 更新
nix flake update

# home-manager 再適用
home-manager switch --flake .#x86_64-linux    # Linux
home-manager switch --flake .#aarch64-darwin  # macOS
```


---

# LICENSE
MIT
