# nazozokc's Nix Dotfiles

Nixで管理された多環境対応のdotfilesです。Linux (x86_64/arm64) と macOS (arm64) をサポートします。

## 概要

このdotfilesは[Flake-First](https://nixos.org/guides/nix-pillages/what-are-flakes.html)のアプローチで管理されており、**Home Manager**と**nix-darwin**を使用して一貫性のある開発環境を構築します。

### 対応環境

| Platform | Architecture | Manager |
|----------|--------------|---------|
| Linux | x86_64 | Home Manager |
| Linux | aarch64 | Home Manager |
| macOS | aarch64 | nix-darwin + Home Manager |

## パッケージ構成

### 共通パッケージ（`modules/tools/packages/`）

すべての環境でインストールされるパッケージ群です。

#### 基本ツール (`base.nix`)
- エディタ: `neovim`, `vscode`, `zed`
- シェル: `fish`, `zsh`, `bash`, `starship`
- CLIツール: `jq`, `bat`, `curl`, `wget`, `zoxide`, `fzf`, `tmux`, `eza`, `yazi`, `bottom`, `just`
- Nix関連: `nix-tree`, `direnv`, `cachix`, `niv`

#### 開発ツール (`dev.nix`)
- Python: `python312`
- JavaScript/TypeScript: `nodejs`, `typescript-language-server`, `pnpm`, `bun`, `deno`
- Rust: `rustc`, `rust-analyzer`
- Nix: `nil`, `nixd`, `nixfmt`
- その他の言語: `clang`, `jdk`, `cargo`, `cmake`, `ninja`, `stylua`

#### CLIアプリケーション (`cli.nix`)
- Git関連: `git`, `gh`, `ghq`, `lazygit`, `gitui`, `tig`
- Docker: `docker`, `lazydocker`
- その他のツール: `tree`, `ncdu`, `delta`, `tldr`, `uv`, `renamer`, `inetutils`

#### GUIアプリケーション (`gui.nix`)
- ターミナル: `wezterm`, `ghostty`
- 開発: `obsidian`
- その他: `audacity`, `spotify`, `discord`, `tor-browser`

### Linux専用パッケージ (`modules/home-manager/linux.nix`)
- クリップボード: `xclip`, `wl-clipboard`
- 音声: `pulseaudio`, `pavucontrol`
- アーカイブ: `unzip`, `zip`
- ネットワーク: `nmap`

### macOS専用パッケージ (`modules/home-manager/darwin.nix`)
- 基本コマンド: `coreutils`, `gnused`, `gawk`, `inetutils`

## モジュール構造

```
nix/
├── modules/
│   ├── darwin/
│   │   ├── darwin.nix      # nix-darwin entry point
│   │   └── system.nix      # macOSシステム設定
│   ├── home-manager/
│   │   ├── darwin.nix      # macOS用home-manager設定
│   │   ├── linux.nix       # Linux用home-manager設定
│   │   ├── symlinks.nix    # dotfilesシンボリックリンク
│   │   └── tools-read.nix  # ツールパッケージ読み込み
│   └── tools/
│       ├── packages/
│       │   ├── base.nix    # 基本ツール
│       │   ├── cli.nix     # CLIツール
│       │   ├── dev.nix     # 開発ツール
│       │   ├── gui.nix     # GUIアプリ
│       │   └── default.nix # パッケージグループ定義
│       └── program/
│           └── gh/         # GitHub CLI拡張
├── overlays/
│   ├── ai-tools.nix        # AIツールオーバーレイ
│   ├── nix-index.nix       # nix-index拡張
│   ├── node-packages.nix   # Node.jsパッケージ拡張
│   └── default.nix         # オーバーレイ統合
├── cachix.nix              # Cachixキャッシュ設定
├── shared.nix              # Linux/macOS共通設定
└── README.md
```

## 使用方法

### 環境構築（Linux）

```bash
# Home Managerのインストール（初回のみ）
nix run nixpkgs#home-manager -- install

# dotfilesの適用
nix run .#switch
```

### 環境構築（macOS）

```bash
# nix-darwinのインストール（初回のみ）
nix run nix-darwin -- install

# dotfilesの適用
nix run .#switch
```

### その他のコマンド

```bash
# flakeの更新
nix run .#update

# 指定アーキテクチャ向けに適用
# Linux (x86_64)
nix run .#switch
nix run .#update

# Linux (ARM)
nix run .#switch  # homeConfigurations.${username}-aarch64が使用される
nix run .#update

# macOS
nix run .#switch  # darwinConfigurations.${username}が使用される
nix run .#update
```

## 設計思想

- **シンプルかつ多機能**: 最小限の設定で最高の開発体験を提供
- **環境非依存**: どの環境でも再現可能な設定
- **かっこいい**: CLIから抜けられない人のための環境
- **最小限のコード**: 機能追加時に不要な設定は追加しない

## 参考リポジトリ

- **最も参照**: [ryoppippi/dotfiles](https://github.com/ryoppippi/dotfiles)
- **ほどほど参照**: [mozumasu/dotfiles](https://github.com/mozumasu/dotfiles)
- **構成参考**: [ntsk/dotfiles](https://github.com/ntsk/dotfiles)

## ディレクトリ構造（全体）

```
~/ghq/github.com/nazozokc/dotfiles/
├── nix/               # Nixパッケージ・モジュール
├── fish/             # fish shell設定
├── nvim/             # neovim設定
├── wezterm/          # wezterm設定
├── bash/             # bash設定
├── starship/         # starship設定
├── zsh/              # zsh設定
├── agents/           # AIエージェント設定
├── opencode/         # opencode設定
└── ghostty/          # ghostty設定
```

## シンボリックリンク

Home Managerを通じて以下のシンボリックリンクが自動作成されます：

```
~/.config/fish      -> dotfiles/fish
~/.config/nvim      -> dotfiles/nvim
~/.config/wezterm   -> dotfiles/wezterm
~/.config/bash      -> dotfiles/bash
~/.config/starship.toml -> dotfiles/starship/starship.toml
~/.config/ghostty   -> dotfiles/ghostty
~/.zshrc            -> dotfiles/zsh/zshrc
~/.agents           -> dotfiles/agents
~/.config/opencode  -> dotfiles/opencode
```

## オーバーレイ

カスタムパッケージをnixpkgsに追加するためのオーバーレイを定義しています。

- **ai-tools.nix**: `opencode`, `coderabbit-cli`などのAIツール
- **node-packages.nix**: TypeScript, ESLint, PrettierなどのNode.jsツール

## プロジェクト情報

- **Author**: nazozokc
- **Repository**: https://github.com/nazozokc/dotfiles
