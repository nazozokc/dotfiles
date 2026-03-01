# 最初にやること
`/home/nazozokc/.agents/CLAUDE.md`
上を読み込んでください

# Nix Dotfiles 構成ガイド

## 概要

このdotfilesは `flake.nix` をエントリーポイントとし、Linux/macOS両対応の開発環境を構築します。

## システム構成

| コンポーネント | Linux, ARM-linux| macOS |
|--------------|-------|-------|
| システム設定 | home-manager | nix-darwin |
| ユーザーパッケージ | home-manager | home-manager (nix-darwin統合) |
| シェル | fish | fish |

## パッケージ管理のアーキテクチャ

### 共通パッケージ (`nix/modules/tools/packages.nix`)
以下のパッケージは両OS共通でインストールされます:
- エディタ: neovim, vscode, zed
- シェル: fish, zsh, bash, starship
- CLIツール: jq, bat, curl, wget, zoxide, fzf, tmux, eza, yazi, bottom, just
- Nix関連: nix-tree, direnv, cachix, niv
- 言語: python312, nodejs_24, bun, deno, rustc
- LSP/フォーマッタ: rust-analyzer, nil, nixd, nixfmt, stylua
- Git関連: git, gh, ghq, lazygit, gitui
- GUI: wezterm, audacity, spotify, discord, ghostty

### Linux専用パッケージ (`nix/modules/home-manager/linux.nix`)
- xclip, wl-clipboard (クリップボード)
- pulseaudio, pavucontrol (音声)
- unzip, zip (アーカイブ)
- nmap (ネットワーク)

### macOS専用パッケージ (`nix/modules/home-manager/darwin.nix`)
- coreutils, gnused, gawk, inetutils (基本コマンド)

### macOSシステムパッケージ (`nix/modules/darwin/system.nix`)
- git (nix-darwinのenvironment.systemPackagesで管理)

## モジュール構造

```
nix/
├── modules/
│   ├── darwin/
│   │   ├── darwin.nix
│   │   └── system.nix
│   ├── home-manager/
│   │   ├── darwin.nix
│   │   ├── linux.nix
│   │   ├── symlinks.nix
│   │   └── tools-read.nix
│   └── tools/
│       ├── packages/
│       │   ├── base.nix
│       │   ├── cli.nix
│       │   ├── default.nix
│       │   ├── dev.nix
│       │   └── gui.nix
│       └── program/
│           ├── gh/
│           │   └── gh.nix
│           └── gh.nix
├── overlays/
│   ├── ai-tools.nix
│   ├── default.nix
│   └── gh.nix
├── packages/
│   └── node/
│       ├── default.nix
│       └── update.sh
├── AGENT.md
├── README.md
├── cachix.nix
└── shared.nix
```

## コマンド

```bash
# 環境切り替え (OS自動検出)
nix run .#switch

# flake更新
nix run .#update

# Node.jsパッケージ更新
nix run .#update-node-packages
```

## home-managerの動作

- **Linux**: home-managerが独立して動作し、~/.config/home-manager以下にファイルを生成
- **macOS**: nix-darwinのモジュールとしてhome-managerを統合 (`home-manager.useUserPackages = true`)

## 参考リポジトリ
下のリンクが私のdotfilesレポジトリです。必要に応じて参照してください
<https://github.com/nazozokc/Dotfiles>

下の3つのリンクは私がnix環境を実現するに当たって参照したレポジトリです、必要に応じて参照してください。
**一番参照**
<https://github.com/ryoppippi/dotfiles>

**少し参照**
<https://github.com/mozumasu/dotfiles>

**あまり参照はないが参考にはなりそう** 
<https://github.com/ntsk/dotfiles>
