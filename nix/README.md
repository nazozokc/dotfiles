# Nix Dotfiles 構成ガイド

## 概要

このdotfilesは `flake.nix` をエントリーポイントとし、Linux/macOS/WSL の3環境に対応した開発環境を構築します。

## システム構成

| コンポーネント     | Linux / WSL  | macOS (Apple Silicon)         | macOS (Intel)                   |
| ------------------ | ------------ | ----------------------------- | ------------------------------- |
| nixpkgs            | unstable     | unstable                      | 26.05 (`nixpkgs-26.05-darwin`)  |
| システム設定       | home-manager | nix-darwin                    | nix-darwin (`nix-darwin-26.05`) |
| ユーザーパッケージ | home-manager | home-manager (nix-darwin統合) | home-manager (nix-darwin統合)   |
| シェル             | fish         | fish                          | fish                            |

## Intel Mac (x86_64-darwin) について

nixpkgs 26.11 で `x86_64-darwin` のサポートが削除されたため、Intel Mac では最後に対応している **nixpkgs 26.05 系の専用スタック**（`nixpkgs-intel` / `home-manager-intel` / `darwin-intel` など、2026年末まで保守）を使用します。`flake.nix` の `pkgsFor` / `mkDarwinConfig` が system に応じてスタックを切り替えます。

### Intel Mac 固有の制約

- `home.stateVersion` は home-manager 26.05 の制約により `mkForce "26.05"` に固定。
- 以下のパッケージは nixpkgs 側の非対応により **Intel Mac ではインストールされません**:
  - `oterm` — fastmcp → duckdb → pyarrow → arrow-cpp（x86_64-darwin で broken）
  - `aider-chat-full` — grep-ast → tree-sitter-language-pack（x86_64-darwin のバンドルなし）
- 対象設定: `darwinConfigurations.nazozokc-x86_64`（Apple Silicon は `nazozokc`）

## パッケージ管理のアーキテクチャ

パッケージは `nix/modules/home/packages/` 配下でカテゴリ別に分類されています。`packages/default.nix` が全カテゴリを flatten して `home.packages` に渡します。

### 共通パッケージ (`nix/modules/home/packages/`)

#### base (`base/default.nix`)

基礎 CLI ツール。全環境でインストールされる。

- **シェル**: nushell, zsh
- **CLI**: jq, curl, wget, zoxide, tree, btop, fastfetch, onefetch, eza, tmux, uv, ncdu, tldr, pet, just, dig
- **ファイラー**: yazi
- **Nix**: nix-tree, cachix, niv, nix-output-monitor, nh
- **Docker**: docker, lazydocker
- **Git/GitHub**: gh, ghq, git-wt, jujutsu, gitui, git-secrets, tig, ghgrab
- **ユーティリティ**: presenterm, trash-cli, rename, inetutils, lsof, comma, aria2, mise, cmake
- **認証**: bitwarden-cli, bitwarden-desktop, _1password-cli
- **メール**: aerc, neomutt, himalaya

#### dev (`dev/default.nix`)

開発言語・ツール。

- **汎用**: prettier, telescope
- **Python**: python312
- **JavaScript/TypeScript**: nodejs_latest, typescript-language-server, bun, deno, yarn
- **Rust**: rustc, rust-analyzer
- **Nix**: nil, nixd, nixfmt
- **Go**: go, go-tools
- **Lua**: stylua
- **Java**: jdk
- **C/C++**: clang, clang-tools
- **YAML**: yamlfmt, efm-langserver
- **ビルドツール**: cargo, cmake, ninja
- **テスト**: playwright-driver
- **DB**: sqlite
- **セキュリティ**: aircrack-ng, crunch
- **Linux固有**: vite, chromium

#### ai (`ai/default.nix`)

AI / LLM 関連ツール。

- ollama, opencode, codex, claude-monitor, claude-code

#### gui (`gui/default.nix`)

GUI アプリケーション。

- **共通**: audacity, vscode, zed
- **x86_64-linux固有**: tor-browser
- **macOS**: chatgpt, obsidian, raycast, vscodium
- **x86_64-linux + macOS**: spotify, discord, google-chrome

#### experimental (`experimental/default.nix`)

実験的ツール。

- pi-coding-agent, grok-cli, qwen-code

### Linux固有パッケージ (`nix/modules/linux/packages.nix`)

- クリップボード: xclip, wl-clipboard
- 音声: alsa-utils, playerctl, pulseaudio, pavucontrol, sox
- アーカイブ: unzip, zip
- ネットワーク: ethtool, mtr, nmap
- システム監視: duf, hyperfine, iotop, lm_sensors, procs, sd, sysstat, bandwhich
- フォント: fontconfig, nerd-fonts.jetbrains-mono
- セキュリティ: gnupg, openssh, pass, polkit_gnome
- XDG: file, libnotify, xdg-user-dirs, xdg-utils
- ウィンドウマネージャ: herdr
- Wayland: grim, slurp, brightnessctl, rofi, waybar, dunst, awww, hyprlock, hypridle, wlogout

### WSL固有パッケージ (`nix/modules/wsl/packages.nix`)

- クリップボード: xclip, wl-clipboard
- アーカイブ: unzip, zip
- ネットワーク: nmap
- フォント: fontconfig
- セキュリティ: gnupg, openssh
- XDG: file, libnotify, xdg-user-dirs, xdg-utils

## クロスプラットフォーム設定共有

以下の設定ファイルは Nix（Linux/macOS/WSL）と Windows（PowerShell 7）で同じファイルを共有しています：

| ツール         | 共有ファイル                              | Nixでの管理方法                                   | Windowsでの管理方法    |
| -------------- | ----------------------------------------- | ------------------------------------------------- | ---------------------- |
| git            | `git/config`, `git/aliases`, `git/ignore` | `programs.git.includes` + `home.file` でデプロイ  | `apply.ps1` で symlink |
| starship       | `starship/starship.toml`                  | `home.file` でデプロイ                            | `apply.ps1` で symlink |
| lazygit        | `lazygit/config.yml`                      | `home.file` でデプロイ                            | `apply.ps1` で symlink |
| bat            | `bat/config`                              | `home.file` でデプロイ                            | `apply.ps1` で symlink |
| nvim           | `nvim/`                                   | `home.file` で symlink                            | `apply.ps1` で symlink |
| wezterm        | `wezterm/`                                | `home.file` で symlink                            | `apply.ps1` で symlink |
| opencode       | `opencode/`                               | `xdg.configFile` + `home.file` でデプロイ・リンク | `apply.ps1` で symlink |
| efm-langserver | `efm-langserver/`                         | `home.file` でデプロイ                            | `apply.ps1` で symlink |

各 `programs/<name>/default.nix` では `dotfilesDir` を使ってリポジトリルートの共有ファイルを参照しています。

## モジュール構造

```
nix/
├── shared.nix                         # 共通設定 (username, stateVersion, xdg)
├── lib/
│   └── pkgs.nix                       # pkgsFor (nixpkgs インスタンス生成 + Intelスタック切替)
├── modules/
│   ├── home/                          # home-manager 共通モジュール
│   │   ├── default.nix                # エントリーポイント (Linux/WSL 共通)
│   │   ├── wsl.nix                    # WSL エントリーポイント (packages なし)
│   │   ├── dotfiles-link.nix          # fish/wezterm/zsh/bash/my_scripts の symlink 管理
│   │   ├── tools-read.nix             # Linux 用ツール読み取り
│   │   ├── agent-skills.nix           # opencode agent-skills-nix 設定
│   │   ├── programs-common.nix        # 共通 program モジュール一括 import
│   │   ├── systemd/                   # systemd タイマー (nix-store GC)
│   │   │   └── default.nix
│   │   ├── packages/                  # パッケージカテゴリ分類
│   │   │   ├── default.nix            # 全カテゴリ flatten エントリ
│   │   │   ├── base/default.nix       # 基礎 CLI ツール
│   │   │   ├── dev/default.nix        # 開発言語・ツール
│   │   │   ├── ai/default.nix         # AI / LLM ツール
│   │   │   ├── gui/default.nix        # GUI アプリ
│   │   │   ├── experimental/default.nix # 実験的ツール
│   │   │   ├── treefmt.nix            # treefmt (nix flake パーツ)
│   │   │   └── wsl.nix               # WSL 向けパッケージ (category ラッパー)
│   │   └── programs/                  # プログラム設定 (programs-common.nix 経由)
│   │       ├── bat/                   # bat (CLI ファイルビューア)
│   │       ├── claude-code/           # Claude Code
│   │       ├── cmux/                  # cmux (tmux ラッパー)
│   │       ├── direnv.nix             # direnv
│   │       ├── docker/                # Docker
│   │       ├── fish/                  # fish シェル
│   │       ├── fzf/                   # fzf (ファジーファインダー)
│   │       ├── gh/                    # GitHub CLI
│   │       ├── gh-dash/               # gh dashboard
│   │       ├── ghostty.nix            # Ghostty ターミナル
│   │       ├── git/                   # git (programs.git + delta)
│   │       ├── jujutsu/               # jujutsu (VCS)
│   │       ├── lazygit/               # lazygit (TUI git)
│   │       ├── nvim/                  # Neovim (直接 import)
│   │       ├── ollama/                # Ollama (ローカル LLM)
│   │       ├── opencode/              # OpenCode (AI エージェント)
│   │       ├── sops/                  # sops-nix (シークレット管理)
│   │       ├── starship/              # Starship プロンプト
│   │       ├── tmux/                  # tmux
│   │       ├── vscode/                # VSCode 設定
│   │       ├── yazi/                  # yazi (ファイラー)
│   │       ├── aerospace.nix          # AeroSpace (macOS タイルウィンドウ)
│   │       └── herdr/                 # Herdr (tmux ライクなプレフィックス)
│   ├── linux/                         # Linux 固有設定
│   │   ├── build.nix                  # 設定生成ヘルパー (mkLinuxHomeConfig)
│   │   ├── default.nix                # エントリーポイント (nixGL, hypr/waybar/rofi/dunst link)
│   │   ├── packages.nix               # Linux 専用パッケージ
│   │   └── system.nix                 # ロケール・XDG・セッション変数
│   ├── macos/                         # macOS 固有設定
│   │   ├── build.nix                  # 設定生成ヘルパー (mkDarwinConfig)
│   │   ├── default.nix                # エントリーポイント
│   │   ├── darwin-home.nix            # macOS 固有 home-manager 設定
│   │   └── system.nix                 # nix-darwin システム設定
│   └── wsl/                           # WSL 固有設定
│       ├── build.nix                  # 設定生成ヘルパー (mkWSLHomeConfig)
│       ├── default.nix                # エントリーポイント
│       ├── packages.nix               # WSL 専用パッケージ
│       ├── system.nix                 # WSL 固有設定 (.wslconfig など)
│       └── tools-read.nix             # WSL 用ツール読み取り
├── overlays/                          # カスタムoverlay
│   ├── default.nix                    # overlay コンポーザ
│   ├── ai-tools.nix                   # AI ツール
│   ├── bitwarden-cli.nix              # Bitwarden CLI
│   ├── compiler-rt.nix                # compiler-rt
│   ├── fish-plugins.nix               # fish プラグイン
│   ├── node-packages.nix              # Node.js パッケージ
│   └── pipx.nix                       # pipx
├── README.md                          # このファイル
├── AGENTS.md                          # AI エージェント用メモリ
└── shared.nix                         # 共通設定
```

## コマンド

```bash
# 環境切り替え (OS自動検出 + 事前チェック)
nix run .#switch

# ビルドのみ (切り替えなし)
nix run .#build

# flake更新
nix run .#update
```

### 信頼性向上

- `nix run .#switch` は実行前に `nix flake check --no-build` を自動実行し、評価エラーを事前に検出します。

### 信頼性向上

- `nix run .#switch` は実行前に `nix flake check --no-build` を自動実行し、評価エラーを事前に検出します。
- `home-manager` / `nix-darwin` は nixpkgs の最新版から取得するため、バージョンドリフトが発生する可能性があります。バージョンを固定したい場合は `nix build` + `./result/activate` パターンの利用を検討してください。

## home-manager の動作

- **Linux**: home-manager が独立して動作。`targets.genericLinux` で NixOS 以外の Linux にも対応
- **macOS**: nix-darwin のモジュールとして home-manager を統合 (`home-manager.useUserPackages = true`)
- **WSL**: home-manager が独立して動作。GUI パッケージは除外（`wsl.nix` が `packages/` を読まない）

## devShells

```bash
# デフォルト (git, just)
nix develop

# Nix 開発用 (nixfmt, statix, deadnix, nil, nixd)
nix develop .#nix

# エディタ設定用 (stylua, nodejs)
nix develop .#editors
```

## モジュール間の依存関係

```
flake.nix
├── pkgsFor (nix/lib/pkgs.nix)          → nixpkgs インスタンス生成 (Intelスタック切替)
├── Linux:   mkLinuxHomeConfig (nix/modules/linux/build.nix)
│              → nix/modules/home/      + nix/modules/linux/
├── WSL:     mkWSLHomeConfig (nix/modules/wsl/build.nix)
│              → nix/modules/home/wsl.nix + nix/modules/wsl/
└── macOS:   mkDarwinConfig (nix/modules/macos/build.nix)
               → nix/modules/macos/     + nix/modules/home/ (via nix-darwin)
```

- `programs-common.nix` が共通の program モジュールを一括 import する
- `dotfiles-link.nix` が共有ファイルの symlink を一括管理する
- `packages/default.nix` がカテゴリ別パッケージを flatten して `home.packages` に渡す
- Linux は `nixGL` で wezterm/ghostty をラップして非 NixOS 環境の GPU ライブラリに対応

## home.stateVersion ポリシー

- 定義位置: `nix/shared.nix`
- 現在値: `26.11`
- **原則: 一度設定したら絶対に変更しない**
- 互換性優先のため普段は固定する。
- 更新は以下の条件を全て満たした場合のみ許可される:
  1. 変更理由をPR本文に明記
  2. `nix flake check` 通過
  3. `nix run .#build` 通過
  4. dotfilesリンク・主要CLI起動確認結果をPRに記録
- **注意**: stateVersion の更新はデータの破損や設定の不整合を引き起こす可能性があるため、避けること。

## 参考リポジトリ

- **一番参照**: <https://github.com/ryoppippi/dotfiles>
- **少し参照**: <https://github.com/mozumasu/dotfiles>
- **参考にはなりそう**: <https://github.com/ntsk/dotfiles>

## 運用ポリシー

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
