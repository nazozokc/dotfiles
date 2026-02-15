# Nazozo Dotfiles

このリポジトリは Linux / macOS 両対応で Nix による dotfiles 管理を行う構成です。  
macOS では **nix-darwin** を利用し、Home Manager と連携させています。

---

## 対応 OS

- Linux: `x86_64-linux` (Arch Linux など)
- macOS: `aarch64-darwin` (Apple Silicon)

---

## 前提条件

- [Nix](https://nixos.org/download.html) がインストール済みであること
  - macOS の場合は Nix 2.15+ 推奨
- Linux / macOS 両方で `nix` コマンドが使えること

---

## 初回導入 (nix run を使用)

```bash
cd ~
git clone https://github.com/nazozokc/dotfiles.git
cd dotfiles

# Home Manager + pkgs の初回セットアップ
nix run .#switch
```

- Linux / macOS 両方で `nix run .#switch` だけで初回セットアップ可能
- Home Manager による dotfiles のリンクとパッケージインストールが行われます
- macOS では nix-darwin を通して Home Manager 設定も有効化されます

---

## 通常の更新・再適用

```bash
# dotfilesやパッケージ更新
nix run .#switch

# バージョン更新
nix run .#update

# Node.js パッケージ更新
nix run .#update-node-packages
```

- Linux は Home Manager 単体で管理
- macOS は nix-darwin を通して Home Manager を管理
- GUIアプリも Nix で管理可能
- 既存の PATH 環境を壊さず管理できます

---

## 管理対象一覧

- **シェル**: fish
- **エディタ**: Neovim, VSCode 設定
- **CLIツール**: `nix/modules/tools/packages.nix`
- **Home Manager**: dotfiles (`.config/*`), ホームディレクトリリンク管理 (`checkFilesChanged`, `checkLinkTargets`)
- **macOS限定**: nix-darwin によるシステム設定
- **Node.js**: Nix 経由でパッケージ管理 (`nix run .#update-node-packages`)

---

## 注意事項

- OS本体やカーネルは pacman（Linux）や macOS 標準管理に任せる
- Home Manager によるリンクや設定は既存の dotfiles を上書きする場合があります

# Activity

![Alt](https://repobeats.axiom.co/api/embed/c4db566c918002010974abbbcc1ee5150bed51da.svg "Repobeats analytics image")
