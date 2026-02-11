# Nazozo Dotfiles

このリポジトリは Linux / macOS 両対応で Nix による dotfiles 管理を行う構成です。
macOS では **nix-darwin** を利用し、Home Manager と連携させています。

---

## 対応 OS

* Linux: `x86_64-linux` (Arch Linux など)
* macOS: `aarch64-darwin` (Apple Silicon)

---

## 前提条件

* [Nix](https://nixos.org/download.html) がインストール済みであること

  * macOS の場合は Nix 2.15+ 推奨
* Linux / macOS 両方で `nix` コマンドが使えること

---

## 初回導入 (nix run を使用)

### 1. リポジトリのクローン

```bash
cd ~
git clone https://github.com/nazozokc/dotfiles.git
cd dotfiles
```

### 2. flake の初回実行

#### Linux:

```bash
nix run .#homeConfigurations.x86_64-linux.activationPackage
```

* このコマンドは Home Manager の初回セットアップを行います
* `.config` 以下の dotfiles がリンクされ、パッケージもインストールされます

#### macOS:

```bash
nix run .#darwinConfigurations.aarch64-darwin.activationPackage
```

* nix-darwin を使った初回セットアップ
* Home Manager 設定も macOS 上で有効になります

---

## 通常の更新・再適用

* Linux:

```bash
home-manager switch --flake .#x86_64-linux
```

* macOS:

```bash
darwin-rebuild switch --flake .#aarch64-darwin
```

---

## ファイル構成

```
dotfiles/
├─ flake.nix
├─ nix/
│  ├─ modules/
│  │  ├─ shared.nix
│  │  ├─ os/
│  │  │  ├─ linux.nix
│  │  │  └─ darwin.nix
│  │  └─ pkgs/
│  │      ├─ cli.nix
│  │      └─ gui.nix
│  └─ config-sym.nix
```

* `shared.nix` … Linux/macOS 共通の Home Manager 設定
* `linux.nix` … Linux 専用の設定
* `darwin.nix` … macOS 専用の設定
* `cli.nix` / `gui.nix` … パッケージ管理設定
* `config-sym.nix` … dotfiles のシンボリックリンク管理

---

## 補足

* Linux は Home Manager 単体で管理
* macOS は nix-darwin を通して Home Manager を管理
* GUI アプリも Nix 経由で管理可能
* 既存の PATH 環境を壊さずに管理できる構成になっています
* `nix run` を使うことで初心者でも初回セットアップが簡単にできます
