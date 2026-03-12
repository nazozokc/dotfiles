# Nazozo Dotfiles

このリポジトリは Linux / macOS 両対応で Nix による dotfiles 管理を行う構成です。  
macOS では **nix-darwin** を利用し、Home Manager と連携させています。

---

# 注意事項

    本dotfilesは私(nazozokc)が個人的に使用しているものです。
    そのため、本番環境でのスクリプトの実行やconfigの使用は推奨しません。
    本リポジトリに掲載した内容を使用したことに対するいかなる損害、損失、
    またはそれに類するものに関して、私、及び貢献者は一切の責任を負わないものとし、
    このリポジトリに掲載した内容を使用するユーザーはそれを理解したものとします。

---

## 対応 OS

- Linux: `x86_64-linux` (Arch Linux など)
- Linux: `aarch64-linux`(ARM linux)
- macOS: `aarch64-darwin` (Apple Silicon)

---

## 前提条件

- [Nix](https://nixos.org/download.html) がインストール済みであること
  - インストール方法は下部の「Nix のインストール」を参照
  - macOS の場合は Nix 2.15+ 推奨
- Linux / macOS 両方で `nix` コマンドが使えること

## Nix のインストール

### Linux (推奨: マルチユーザーインストール)

```bash
# マルチユーザーインストール (sudo が必要)
sh <(curl -L https://nixos.org/nix/install) --daemon --yes

# シェルを再起動するかログインし直す
exec $SHELL
```

### macOS

```bash
# シングルユーザーインストール (推奨)
sh <(curl -L https://nixos.org/nix/install) --no-daemon

# またはマルチユーザーインストール
sh <(curl -L https://nixos.org/nix/install) --daemon --yes

# シェルを再起動するかログインし直す
exec $SHELL
```

### インストール確認

```bash
nix --version
nix-env --version
```

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

---

## 注意事項

- OS本体やカーネルは pacman（Linux）や macOS 標準管理に任せる
- Home Manager によるリンクや設定は既存の dotfiles を上書きする場合があります

# Activity

![Alt](https://repobeats.axiom.co/api/embed/c4db566c918002010974abbbcc1ee5150bed51da.svg "Repobeats analytics image")

# LICENSE

MIT
