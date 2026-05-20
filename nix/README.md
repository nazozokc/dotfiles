# Nix Dotfiles 構成ガイド

## 概要

このdotfilesは `flake.nix` をエントリーポイントとし、Linux/macOS両対応の開発環境を構築します。

## システム構成

| コンポーネント     | Linux, ARM-linux | macOS                         |
| ------------------ | ---------------- | ----------------------------- |
| システム設定       | home-manager     | nix-darwin                    |
| ユーザーパッケージ | home-manager     | home-manager (nix-darwin統合) |
| シェル             | fish             | fish                          |

## パッケージ管理のアーキテクチャ

### 共通パッケージ (`nix/home/packages/default.nix`)

以下のパッケージは両OS共通でインストールされます:

- エディタ: neovim, vscode, zed
- シェル: fish, zsh, bash, starship
- CLIツール: jq, bat, curl, wget, zoxide, fzf, tmux, eza, yazi, bottom, just
- Nix関連: nix-tree, direnv, cachix, niv
- 言語: python312, nodejs_24, bun, deno, rustc
- LSP/フォーマッタ: rust-analyzer, nil, nixd, nixfmt, stylua
- Git関連: git, gh, ghq, lazygit, gitui
- GUI: wezterm, audacity, spotify, discord, ghostty

### Linux専用パッケージ (`nix/systems/linux.nix`)

- xclip, wl-clipboard (クリップボード)
- pulseaudio, pavucontrol (音声)
- unzip, zip (アーカイブ)
- nmap (ネットワーク)

### macOS専用パッケージ (`nix/home/packages/gui.nix`)

- raycast (GUIランチャー)

### macOSシステムパッケージ (`nix/systems/darwin.nix`)

- git (nix-darwinのenvironment.systemPackagesで管理)

## モジュール構造

```
nix/
├── home/                          # home-manager 関連
│   ├── default.nix                # エントリーポイント
│   ├── dotfiles-link.nix
│   ├── tools-read.nix
│   ├── tools-read-wsl.nix
│   ├── agent-skills.nix
│   ├── programs-common.nix
│   ├── packages/                  # パッケージインストール
│   │   ├── base.nix
│   │   ├── cli.nix
│   │   ├── default.nix
│   │   ├── dev.nix
│   │   ├── gui.nix
│   │   ├── treefmt.nix
│   │   └── wsl.nix
│   └── programs/                  # プログラム設定
│       ├── bat/
│       ├── claude-code/
│       ├── docker/
│       ├── fzf/
│       ├── gh/
│       ├── git/
│       ├── jujutsu/
│       ├── lazygit/
│       ├── nvim/
│       │   └── default.nix
│       ├── ollama/
│       ├── opencode/
│       ├── sops/
│       ├── starship/
│       ├── tmux/
│       ├── vscode/
│       ├── yazi/
│       ├── direnv.nix
│       └── ghostty.nix
├── systems/                       # OS固有システム設定
│   ├── darwin.nix
│   ├── linux.nix
│   └── wsl.nix
├── overlays/                      # カスタムoverlay
│   ├── ai-tools.nix
│   ├── default.nix
│   └── node-packages.nix
├── README.md
├── AGENTS.md
└── shared.nix
```

## コマンド

```bash
# 環境切り替え (OS自動検出)
nix run .#switch

# ビルドのみ (切り替えなし)
nix run .#build

# flake更新
nix run .#update
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

## 運用ポリシー（追加）

### CI品質ゲート

- PR の必須チェックは以下。
  - `nix flake check`
  - `nix fmt -- --ci`
- 上記は Linux / macOS の両方で実行する。

### sops-nix シークレット運用

- 暗号化ファイルは `secrets/common.yaml` を使用する。
- home-manager の展開先:
  - `api/github_token` → `~/.config/secrets/github_token`
  - `api/openai_api_key` → `~/.config/secrets/openai_api_key`
  - `api/anthropic_api_key` → `~/.config/secrets/anthropic_api_key`
- AGE鍵は `~/.config/sops/age/keys.txt`。
- `secrets/common.yaml` がない環境では secret を読まない（復号不要のCIを壊さないため）。

### home.stateVersion 更新ルール

- 定義位置: `nix/shared.nix`
- 現在値: `26.05`
- 互換性優先のため普段は固定する。
- 更新時は以下を必須にする。
  1. 変更理由をPR本文に明記
  2. `nix flake check` 通過
  3. `nix run .#build` 通過
  4. dotfilesリンク・主要CLI起動確認結果をPRに記録
