# Wiki

[![DeepWiki](https://img.shields.io/badge/DeepWiki-ryoppippi%2Fdotfiles-blue.svg?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACwAAAAyCAYAAAAnWDnqAAAAAXNSR0IArs4c6QAAA05JREFUaEPtmUtyEzEQhtWTQyQLHNak2AB7ZnyXZMEjXMGeK/AIi+QuHrMnbChYY7MIh8g01fJoopFb0uhhEqqcbWTp06/uv1saEDv4O3n3dV60RfP947Mm9/SQc0ICFQgzfc4CYZoTPAswgSJCCUJUnAAoRHOAUOcATwbmVLWdGoH//PB8mnKqScAhsD0kYP3j/Yt5LPQe2KvcXmGvRHcDnpxfL2zOYJ1mFwrryWTz0advv1Ut4CJgf5uhDuDj5eUcAUoahrdY/56ebRWeraTjMt/00Sh3UDtjgHtQNHwcRGOC98BJEAEymycmYcWwOprTgcB6VZ5JK5TAJ+fXGLBm3FDAmn6oPPjR4rKCAoJCal2eAiQp2x0vxTPB3ALO2CRkwmDy5WohzBDwSEFKRwPbknEggCPB/imwrycgxX2NzoMCHhPkDwqYMr9tRcP5qNrMZHkVnOjRMWwLCcr8ohBVb1OMjxLwGCvjTikrsBOiA6fNyCrm8V1rP93iVPpwaE+gO0SsWmPiXB+jikdf6SizrT5qKasx5j8ABbHpFTx+vFXp9EnYQmLx02h1QTTrl6eDqxLnGjporxl3NL3agEvXdT0WmEost648sQOYAeJS9Q7bfUVoMGnjo4AZdUMQku50McDcMWcBPvr0SzbTAFDfvJqwLzgxwATnCgnp4wDl6Aa+Ax283gghmj+vj7feE2KBBRMW3FzOpLOADl0Isb5587h/U4gGvkt5v60Z1VLG8BhYjbzRwyQZemwAd6cCR5/XFWLYZRIMpX39AR0tjaGGiGzLVyhse5C9RKC6ai42ppWPKiBagOvaYk8lO7DajerabOZP46Lby5wKjw1HCRx7p9sVMOWGzb/vA1hwiWc6jm3MvQDTogQkiqIhJV0nBQBTU+3okKCFDy9WwferkHjtxib7t3xIUQtHxnIwtx4mpg26/HfwVNVDb4oI9RHmx5WGelRVlrtiw43zboCLaxv46AZeB3IlTkwouebTr1y2NjSpHz68WNFjHvupy3q8TFn3Hos2IAk4Ju5dCo8B3wP7VPr/FGaKiG+T+v+TQqIrOqMTL1VdWV1DdmcbO8KXBz6esmYWYKPwDL5b5FA1a0hwapHiom0r/cKaoqr+27/XcrS5UwSMbQAAAABJRU5ErkJggg==)](https://deepwiki.com/nazozokc/dotfiles)

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
