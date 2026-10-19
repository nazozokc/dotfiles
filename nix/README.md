# Nix Dotfiles 構成ガイド

## 概要

このdotfilesは `flake.nix` をエントリーポイントとし、Linux/macOS/WSL の3環境に対応した開発環境を構築します。

## システム構成

| コンポーネント     | Linux (system-manager)                 | Linux (NixOS)                   | macOS (Apple Silicon)         | macOS (Intel)                   |
| ------------------ | -------------------------------------- | ------------------------------- | ----------------------------- | ------------------------------- |
| nixpkgs            | unstable                               | unstable                        | unstable                      | 26.05 (`nixpkgs-26.05-darwin`)  |
| OS 層設定          | system-manager (ネイティブ Linux のみ) | `nixosConfigurations`           | —                             | —                               |
| システム設定       | home-manager                           | `nixos-rebuild`                 | nix-darwin                    | nix-darwin (`nix-darwin-26.05`) |
| ユーザーパッケージ | home-manager                           | home-manager (`nazozokc-nixos`) | home-manager (nix-darwin統合) | home-manager (nix-darwin統合)   |
| シェル             | fish                                   | fish                            | fish                          | fish                            |

## Intel Mac (x86_64-darwin) について

nixpkgs 26.11 で `x86_64-darwin` のサポートが削除されたため、Intel Mac では最後に対応している **nixpkgs 26.05 系の専用スタック**（`nixpkgs-intel` / `home-manager-intel` / `darwin-intel` など、2026年末まで保守）を使用します。`nix/lib/pkgs.nix` の `pkgsFor` / `nix/modules/macos/build.nix` が system に応じてスタックを切り替えます。

### Intel Mac 固有の制約

- `home.stateVersion` は home-manager 26.05 の制約により `mkForce "26.05"` に固定。
- 以下のパッケージは nixpkgs 側の非対応により **Intel Mac ではインストールされません**:
  - `oterm` — fastmcp → duckdb → pyarrow → arrow-cpp（x86_64-darwin で broken）
  - `aider-chat-full` — grep-ast → tree-sitter-language-pack（x86_64-darwin のバンドルなし）
- 対象設定: `darwinConfigurations.nazozokc-x86_64`（Apple Silicon は `nazozokc`）

## パッケージ管理のアーキテクチャ

パッケージは `nix/modules/home/packages/` 配下でカテゴリ別に分類されています。`packages/default.nix` が全カテゴリを flatten して `home.packages` に渡します。

パッケージの置き場所は環境の広さで決める。

| 置き場所                                | 対象                           |
| --------------------------------------- | ------------------------------ |
| `nix/modules/home/packages/<category>/` | 全環境共通                     |
| `nix/lib/packages/shared.nix`           | ネイティブ Linux + WSL 共通    |
| `nix/modules/linux/packages.nix`        | ネイティブ Linux のみ          |
| `nix/modules/wsl/packages.nix`          | WSL のみ（現状は shared のみ） |

**同じパッケージを 2 箇所に書かない。** home-manager は重複を許すが、
片方だけ更新すると挙動が割れる。Linux/WSL の共通分は `nix/lib/packages/shared.nix` に集約する。

### 共通パッケージ (`nix/modules/home/packages/`)

#### base (`base/default.nix`)

基礎 CLI ツール。全環境でインストールされる。

- **シェル**: nushell, zsh
- **CLI**: jq, curl, wget, zoxide, fd, tree, btop, fastfetch, onefetch, eza, which, tmux, uv, ncdu, tldr, pet, just, dig
- **ファイラー**: yazi
- **Nix**: nix-tree, cachix, niv, nix-output-monitor, nh
- **Docker**: docker, lazydocker
- **Git/GitHub**: gh, ghq, git-wt, jujutsu, gitui, git-secrets, ghgrab
- **ユーティリティ**: presenterm, trash-cli
- **その他**: rename, inetutils, comma, aria2, mise, tokei

`cmake` は `dev` のビルドツール側だけ。`bitwarden-cli` は
`nix/overlays/bitwarden-cli.nix` が Darwin ビルドを補修する。

#### dev (`dev/default.nix`)

開発言語・ツール。

- **汎用**: prettier, telescope
- **JavaScript/TypeScript**: nodejs_latest, bun, deno, yarn, pnpm
  - TypeScript / JavaScript の LSP は `typescript-language-server` ではなく **TypeScript 7 内蔵の LSP** を使う。`pkgs.typescript` は TS7（Go ネイティブ実装）で `tsserver` を持たないため、`nix/overlays/typescript.nix` が `tsc --lsp --stdio` 用の `tsgo` をパッケージとして定義し、nvim（`programs/neovim` の `extraPackages`）と opencode（`programs/opencode` の `lsp.typescript`）がそれを使う
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
- aarch64-darwin のみ: codexbar

#### gui (`gui/default.nix`)

GUI アプリケーション。

- **共通**: audacity, vscode
- **x86_64-linux固有**: tor-browser
- **macOS**: chatgpt, obsidian, raycast, vscodium
- **x86_64-linux + macOS**: spotify, discord, google-chrome

#### experimental (`experimental/default.nix`)

実験的ツール。

- pi-coding-agent, grok-cli, qwen-code

### Linux / WSL 共通パッケージ (`nix/lib/packages/shared.nix`)

ネイティブ Linux と WSL の両方に導入する。両モジュールへ並べて書かず、ここへ集約する。

- クリップボード: xclip, wl-clipboard
- アーカイブ: unzip, zip
- ネットワーク: nmap
- フォント: fontconfig
- セキュリティ/認証: gnupg, openssh
- XDG/デスクトップ統合: file, libnotify, xdg-user-dirs, xdg-utils
- ウィンドウマネージャ: herdr

### Linux固有パッケージ (`nix/modules/linux/packages.nix`)

共通分（上の `shared.nix`）はここに書かない。ネイティブ Linux だけのものを置く。

- 音・動画: alsa-utils, pulseaudio, sox
- ネットワーク: ethtool, mtr
- システム監視: duf, hyperfine, iotop, lm_sensors, procs, sd, sysstat, bandwhich
- フォント: nerd-fonts.jetbrains-mono
- セキュリティ/認証: pass, polkit_gnome
- microsoft: teams-for-linux

#### Ambxst へ一本化したパッケージ

`ambxst` (Quickshell 製デスクトップシェル) の導入で以下を削除した。
Ambxst が同一機能を自前で持つため。

| 削除パッケージ | Ambxst 側の担当        |
| -------------- | ---------------------- |
| waybar         | bar                    |
| dunst          | notifications          |
| rofi / vicinae | launcher (fuzzel 同梱) |
| hyprlock       | lockscreen (PAM)       |
| hypridle       | idle / auto-lock       |
| wlogout        | powermenu              |
| awww           | wallpaper manager      |
| grim / slurp   | screenshot             |
| pavucontrol    | 同梱 (apps.nix)        |
| playerctl      | 同梱 (media.nix) + OSD |
| brightnessctl  | 同梱 (tools.nix) + OSD |

残したもの:

- `polkit_gnome` — Ambxst は polkit agent を同梱しない
- `wl-clipboard` — Ambxst は `wl-clip-persist` で履歴を管理するため、
  `wl-copy` / `wl-paste` 自体は nvim など他ツール用に必要

### WSL固有パッケージ (`nix/modules/wsl/packages.nix`)

- 現状は `nix/lib/packages/shared.nix` のみ（GUI パッケージは入れない）
- WSL 専用の GUI パッケージが要になったら、ここへ足す

## クロスプラットフォーム設定共有

以下の設定ファイルは Nix（Linux/macOS/WSL）と Windows（PowerShell 7）で同じファイルを共有しています：

| ツール         | 共有ファイル      | Nixでの管理方法                                   | Windowsでの管理方法    |
| -------------- | ----------------- | ------------------------------------------------- | ---------------------- |
| nvim           | `nvim/`           | `home.file` で symlink                            | `apply.ps1` で symlink |
| wezterm        | `wezterm/`        | `home.file` で symlink                            | `apply.ps1` で symlink |
| opencode       | `opencode/`       | `xdg.configFile` + `home.file` でデプロイ・リンク | `apply.ps1` で symlink |
| efm-langserver | `efm-langserver/` | `home.file` でデプロイ                            | `apply.ps1` で symlink |

`nvim/` `wezterm/` `opencode/` `efm-langserver/` は `dotfilesDir` でリポジトリルートの
ファイルを参照し、`home.file` で symlink する（上記4つ）。

## Nix が生成する設定

git / starship / lazygit / bat は共有ファイルを持たない。設定は
`nix/modules/home/programs/<name>/default.nix` に書き、home-manager のジェネレータが
store へ書き出してから symlink する。

| ツール   | 生成元                              | 生成先                         |
| -------- | ----------------------------------- | ------------------------------ |
| git      | `programs.git.settings` (INI)       | `~/.config/git/config`         |
| git      | `programs.git.ignores` (ignore)     | `~/.config/git/ignore`         |
| starship | `programs.starship.settings` (TOML) | `~/.config/starship.toml`      |
| lazygit  | `programs.lazygit.settings` (YAML)  | `~/.config/lazygit/config.yml` |
| bat      | `programs.bat.config`               | `~/.config/bat/config`         |

- 別ファイルへ逃がしていた `git/aliases` `git/config` `git/ignore` と
  `programs.git.includes` は廃止。alias は `settings.alias` に統合した
- 同じキーを2回書く必要がある箇所（`credential.<url>.helper`）はリスト値にする。
  `toGitINI` が同じキーを2行に展開するので git の
  「空でクリア → 次の値をセット」の指定順が保たれる
- `programs.git.settings` は1つの attrset のままにする。home-manager の gh モジュールも
  同じオプションに attrset を書くため、型 `either gitIniType (listOf gitIniType)` は
  全て同じ形の定義でしか merge できない
- lazygit は `home.activation.validateLazygitSettings` が
  インストール済みバージョンの schema で検証する。設定のミスは switch 時に落ちる

## 適用済み config のメッセージ

`nix run .#switch` の最後 (`linkGeneration` の後) に、
`nix/modules/home/programs/` 配下で有効になっている config の一覧が
アイコン付きで出る。

```
▌ applied program configs (24)
  🦇 bat          TwoDark / less pager
  🥟 bun          BUN_INSTALL を XDG 準拠へ
  🤖 claude-code  settings.json + CLAUDE.md
  ...
```

どの config がその構成で入ってるかを switch 時に把握するため。

### 書き方

`programs/<name>/default.nix` に1エントリ足すだけ:

```nix
dotfiles.programs.bat = {
  icon = "🦇";
  note = "TwoDark / less pager";
};
```

- `icon` — 1絵文字 (2桁幅) を推奨。名前列の桁揃えが崩れるので
  ZWJ シーケンスや複数絵文字は使わない
- `note` — 補足。空なら名前だけ表示する
- attr 名がそのまま一覧の名前になる

### 実装

- 定義は `nix/modules/home/programs/applied.nix`
  (`options.dotfiles.programs` を宣言し `home.activation.appliedPrograms` を組む)
- `programs-common.nix` が先頭で import する。
  `nvim` / `herdr` / `aerospace` は共通 import の外から読み込まれるが
  オプションは同一 namespace なので同じ書き方でよい
- 並びは名前昇順で固定。attrset の列挙順は安定しないため
- 色付きは `noteColor` / `normalColor`。home-manager \_activation が
  定義済みで、`NO_COLOR` と非 tty の判定も既存メッセージと同じ

## モジュール構造

```
nix/
├── shared.nix                         # 共通設定 (username, stateVersion, xdg)
├── lib/                               # flake が使う「値」と「小物」
│   ├── identity.nix                   # username / repoOwner (誰の dotfiles か)
│   ├── packages/shared.nix            # ネイティブ Linux と WSL の共通パッケージ
│   ├── pkgs.nix                       # pkgsFor (nixpkgs インスタンス生成 + Intelスタック切替)
│   ├── shell.nix                      # app 共通シェルヘルパ (require_nix_features / is_wsl ...)
│   └── targets.nix                    # システム別 attr 名・表示 (flakeTarget / hmConfig / sysLabel)
├── flake-parts/                       # flake-parts の import 先 (outputs の実体)
│   ├── dev-shells.nix                 # devShells (default / nix / editors)
│   └── apps/                          # `nix run .#*` の定義
│       ├── common.nix                 # apps 共有のコンテキスト (identity / shell / targets / system-manager)
│       ├── bootstrap.nix              # apps.default = `nix run github:nazozokc/dotfiles`
│       ├── switch.nix                 # apps.switch
│       ├── build.nix                  # apps.build
│       ├── update.nix                 # apps.update
│       ├── config-update.nix          # apps.config-update (設定反映だけ・sudo 不要)
│       ├── nvim-install.nix           # apps.nvim-install (プラグイン input の lock)
│       ├── nvim-update.nix            # apps.nvim-update (プラグイン input の bump)
│       ├── llm-agents.nix              # apps.llm-agents-update (llm-agents.nix 由来のエージェント更新)
│       ├── agent-skills.nix            # apps.agents-skills-update (Agent Skills の更新と自己検証)
│       └── system.nix                 # apps.system-build / system-check / system-switch
├── modules/                           # home-manager / system-manager のモジュール
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
│   │       ├── bun/                   # bun (BUN_INSTALL 系を XDG 準拠に固定)
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
│   │       ├── nvim/                  # Neovim (直接 import, Farm 生成)
│   │       │   ├── default.nix         # programs.neovim 設定 (init.lua / extraWrapperArgs / extraPackages)
│   │       │   └── plugins/           # プラグインの実体とバージョン (nix store)
│   │       │       └── default.nix     # farm 生成 (nvim/nvim-plug-manage/flake.lock が入力)
│   │       ├── ollama/                # Ollama (ローカル LLM)
│   │       ├── opencode/              # OpenCode (AI エージェント)
│   │       ├── sops/                  # sops-nix (シークレット管理)
│   │       ├── starship/              # Starship プロンプト
│   │       ├── tmux/                  # tmux
│   │       ├── vscode/                # VSCode 設定
│   │       ├── yazi/                  # yazi (ファイラー)
│   │       ├── aerospace.nix          # AeroSpace (macOS タイルウィンドウ)
│   │       ├── applied.nix            # 適用メッセージの集約 + 一覧表示
│   │       └── herdr.nix             # Herdr (tmux ライクなプレフィックス)
│   ├── system/                        # OS 層設定 (system-manager, ネイティブ Linux 全ディストロ)
│   │   ├── build.nix                  # 設定生成ヘルパー (mkSystemConfig / hostPlatform 注入)
│   │   ├── default.nix                # エントリーポイント (allowAnyDistro)
│   │   ├── input-method.nix           # fcitx5 グローバル設定と環境変数 (NixOS 両対応)
│   │   ├── locale.nix                 # ja_JP.UTF-8 / en_US.UTF-8 の生成と LANG (NixOS 両対応)
│   │   ├── nix-installation.nix       # Nix 導入モードの宣言と実ホストの検証
│   │   ├── power.nix                  # power-profiles-daemon
│   │   └── sysctl.nix                 # sysctl.d drop-in と tcp_bbr modprobe (NixOS 両対応)
│   ├── nixos/                         # NixOS 固有設定 (nixosConfigurations)
│   │   ├── build.nix                  # 設定生成ヘルパー (mkNixosConfig / nixosSystem)
│   │   ├── default.nix                # エントリーポイント (共有モジュール + system.nix)
│   │   └── system.nix                 # hostName / i18n / users / pipewire / nix.settings
│   ├── hosts/                         # NixOS ホスト定義
│   │   └── nazozokc/                  # x86_64-linux デスクトップ
│   │       ├── default.nix            # boot.loader (systemd-boot) + hardware-configuration import
│   │       └── hardware-configuration.nix # disk layout (実機の nixos-generate-config 出力)
│   ├── linux/                         # Linux 固有設定
│   │   ├── build.nix                  # 設定生成ヘルパー (mkLinuxHomeConfig)
│   │   ├── default.nix                # エントリーポイント (nixGL, zen-browser, ambxst, hypr link)
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
│   ├── pipx.nix                       # pipx
│   └── typescript.nix                 # TS7 内蔵 LSP (tsgo)
├── README.md                          # このファイル
└── AGENTS.md                          # AI エージェント用メモリ
```

## コマンド

```bash
# bootstrap (ghq へ clone/fetch してから自動で switch)
nix run github:nazozokc/dotfiles

# 環境切り替え (OS自動検出 + 事前チェック)
nix run .#switch

# ビルドのみ (切り替えなし)
nix run .#build

# flake更新
nix run .#update

# config のみ反映 (ローカル編集を store へ・home-manager のみ・sudo 不要)
nix run .#config-update

# Neovim プラグインの宣言同期と lock (既存のバージョンは動かさない)
nix run .#nvim-install

# Neovim プラグインを全部更新 (nix flake update)
nix run .#nvim-update

# AI エージェント更新 (llm-agents.nix 由来)
nix run .#llm-agents-update

# Agent Skills の更新と自己検証
nix run .#agents-skills-update
```

### config-update (`apps.config-update`)

ローカル編集を `/nix/store` の config (symlink 先) へ反映する軽量コマンド。

```bash
nix run .#config-update
```

**`#switch` との差分 = flake check と OS 層を外した home-manager のみ。**

|                                             | `#update` | `#config-update` | `#switch`                     |
| ------------------------------------------- | --------- | ---------------- | ----------------------------- |
| `flake.lock` 更新                           | ✅        | ❌               | ❌                            |
| `nix flake check`                           | ❌        | ❌               | ✅                            |
| home-manager (ユーザー層)                   | ❌        | ✅               | ✅                            |
| OS 層 (system-manager / NixOS / nix-darwin) | ❌        | ❌               | ✅                            |
| sudo                                        | ❌        | ❌               | ✅ (ネイティブ Linux / NixOS) |

- **「最新版」はローカル編集の反映のみ**。git pull はしない
- home-manager activation が走るので symlink の 2 系統が両方更新される:
  `mkOutOfStoreSymlink` (`dotfilesDir` = `self.outPath` の store スナップショット) と
  home-manager 生成物 (git / starship / opencode.json など)
- **git 未追跡ファイルは store に含まれない**ため、実行前の `[1/3] 状態確認` で
  `git status --porcelain` の `??` を警告する (新規 config を `git add` しないと反映されない)
- WSL では `check_wslconfig` で Windows 側 `.wslconfig` のずれも検出する
  (nix が適用できない config のため)
- 適用後は `rebuild_ksycoca` で GUI の世代切替検知を助ける (Linux のみ・no-op 保証)
- **macOS は standalone の `homeConfigurations` が無い**ので、
  `darwinConfigurations.<name>.config.home-manager.users.<name>.activationPackage` を
  `nix build --no-link --print-out-paths` で取得して `$out/activate` を直接実行する
  (nix-darwin の OS 層は触らない)。`nom` は `--print-out-paths` の capture を壊すため
  併用しない (実測済み)。**未検証 — 失敗したら `#switch` へ委譲する**
- 完了後、起動中のアプリは旧設定のまま。opencode 等は再起動し新規セッションを開くこと

### nvim-install / nvim-update (`apps.nvim-install` / `apps.nvim-update`)

`nvim/nvim-plug-manage/flake.lock` を書き換えてプラグインの実体とバージョンを更新する。

```bash
# lua/plugins の宣言を flake.nix の inputs へ自動追加してから lock (既存 input のバージョンは動かさない)
nix run .#nvim-install

# 全 input を最新へ bump する
nix run .#nvim-update
```

- `nvim-install` は先に `sync-inputs.lua` (`nvim -l`) を回す。
  `nvim/lua/plugins/*.lua` を読み、flake.nix に無い plugin.name だけを追加してから
  `nix flake lock` を回す。既存 input の url は触らない
  (fork / codeberg 等の URL 例外を保持)。Lua から消えた input は
  orphan として報告するだけで削除しない。
- `nvim-update` は `nix flake update` で全 input を bump する。
- rev と narHash が同時に動くので、ハッシュを手で書く必要は無い。
- GitHub API は未認証だと 60 req/h しか許さない。136 input の lock は確実に超えるため、
  両 app は `gh auth token` を `NIX_CONFIG` の `access-tokens` へ渡してから nix を起動する。
- 反映には `nix run .#switch`。

### llm-agents-update (`apps.llm-agents-update`)

`llm-agents` input (`github:numtide/llm-agents.nix`) を上げて、AI エージェントを更新する。

```bash
# input bump → nix flake check → nix run .#switch
nix run .#llm-agents-update

# 個別に絞る
nix run .#llm-agents-update -- --no-check    # flake check をskip
nix run .#llm-agents-update -- --no-switch   # switch をskip (更新だけ)
```

**更新対象は `opencode` と `coderabbit-cli` のみ。**

`nix/overlays/ai-tools.nix` が llm-agents から nixpkgs へ注入しているのはこの 2 つだけ。
`claude-code` / `codex` / `ollama` / `codexbar` は nixpkgs 由来なので
このコマンドでは更新されない (`nix flake update nixpkgs` の領域)。

- `llm-agents-intel` は **Intel Mac (x86_64-darwin) 上で実行したときだけ**更新する。
  それ以外の環境では input が使われないので bump しても lock に差分が出るだけ。
  判定は `nix/lib/targets.nix` の `isIntelMac` を評価時に解決してシェルへ渡す
  (`nix run` は現在のマシンで評価されるので、実行環境 = 評価対象のシステム)。
- rev の前後を `flake.lock` 直読み (`jq`) で表示する。`nix flake metadata` は
  ネットワークに触れるので使わない。
- 最後に `nix run .#switch` を実行する。ネイティブ Linux では OS 層で sudo 認証が要る。

### agents-skills-update (`apps.agents-skills-update`)

`agent-skills-nix` input (`github:Kyure-A/agent-skills-nix`) を上げ、
`agents/skills/` の整合性を検証する。

```bash
# input bump → 自己検証 → nix flake check → nix run .#switch
nix run .#agents-skills-update

# 個別に絞る
nix run .#agents-skills-update -- --no-check     # flake check をskip
nix run .#agents-skills-update -- --no-switch    # switch をskip
nix run .#agents-skills-update -- --no-validate  # agents/skills/ の検証をskip
```

**`agents/skills/*` は 18 個すべて自前の手書きで upstream origin がない。**
agent-skills-nix の source registry (`registry/sources/*.nix` + npins) は
このリポジトリでは使っていない。所以「更新」は input bump のみで、
スキル実体に対しては自己検証だけを行う。

検証する内容 (すべて `[warn]` または `[fail]` で報告し、`[fail]` が 1 件あれば終了コード 1):

| 検査                | 判定     | 内容                                         |
| ------------------- | -------- | -------------------------------------------- |
| `SKILL.md` の存在   | `[fail]` | `agents/skills/*/SKILL.md` が無い            |
| frontmatter         | `[fail]` | `name` / `description` が無い、または空      |
| name とディレクトリ | `[warn]` | frontmatter の `name` がディレクトリ名と違う |
| name の形式         | `[warn]` | 小文字 slug (`[a-z0-9]` 始まり) でない       |
| name の重複         | `[fail]` | 複数ディレクトリで同じ `name` を使っている   |
| インデックス drift  | 両方     | `agents/CLAUDE.md` との双方向差分            |

- **`agents/CLAUDE.md` のインデックスは自動修正しない。** 報告のみ。
  skill を追加したら `## ./skills/<name>/SKILL.md` の見出しも手で足すこと。
- 検査対象は「評価は通るが意図とずれている」ものだけ。
  source 設定の不備は `discoverCatalog` が評価時に落とし、
  末尾の `nix flake check --no-build` も評価エラーとして検出する。
- `name` は SKILL.md の frontmatter が正で、ディレクトリ名は配置先 merely。
  両者が違うのは致命的ではないため `[warn]` 止まりにしてある。

### bootstrap (`apps.default`)

`nix run github:nazozokc/dotfiles` は `apps.<system>.default` に解決される。

1. `GHQ_ROOT`（既定 `~/ghq`）配下 `github.com/<repoOwner>/dotfiles` を用意する
   - 未クローン: `ghq get`（無ければ `git clone`）
   - クローン済み: `git remote update`（fetch のみ）
   - git も無い: `nix shell nixpkgs#git -c git` で一時的に git を用意
   - clone 先は `nix/lib/identity.nix` の `repoOwner` で決める。ローカルユーザー名
     （同ファイルの `username`）とは別物なので、別ユーザーで運用しても clone 先は変わらない
2. クローン先のリポジトリで `nix/lib/identity.nix` の `username` を `id -un` へ合わせる
   - 値が同じなら触らない
   - `username` の行だけ置換する（コメントと `repoOwner` は残す）
   - 書き換えた場合は `commit` して残す
   - **flake が読む単一ソース**なので、書き換え後はそのまま `switch` に渡せる
3. そのディレクトリから `nix run .#switch` に委譲する
   - ユーザー層・OS 層の適用・OS 自動判定・事前チェック・`.wslconfig` チェックは全て `switch` が持つ
   - NixOS 上では `switch` が `/etc/NIXOS` を検出し、home-manager (`-nixos` 版) →
     `nixos-rebuild switch` へ自動委譲する

- `sudo nix run github:nazozokc/dotfiles` で実行した場合、app 冒頭の
  `demoteToSudoUser` が SUDO_USER として re-exec する
  (`HOME` が `/root` になり ghq root / `identity.nix` の username が
  root になるのを防ぐ)。root 直実行 (SUDO_USER 無し) はエラー退出する

- 手元のリポジトリが正なので、既存 clone の **HEAD・ブランチは変更しない**
  （`nix/lib/identity.nix` の自動同期のみ作業ツリーが変わる）
- `ghq get -u` は内部で `git pull --ff-only` を実行するため使わない
  （ローカルが origin と分岐していると bootstrap 全体が失敗する）
- ghq root は git config の `[ghq] root` を参照しない
  （その config は dotfiles 適用後にしか生成されないため）

### experimental-features の担保

全 app は起動直後に `require_nix_features`（`nix/lib/shell.nix` の `nixFeatureGuard`）を実行する。

- `nix-command` / `flakes` が既に有効な環境では何もしない
- 無効なら **実効値**（`nix config show`）に不足分を加えたものを `NIX_CONFIG` へ
  書き込む。`NIX_CONFIG` はプロセス環境なので子・孫プロセス（app 内の `nix`、
  home-manager / nix-darwin が内部で起動する `nix`）まで継承される
- `experimental-features` は list 型設定で、`NIX_CONFIG` の指定は設定ファイルの値を
  **置き換える**。そのため実効値をそのまま読み戻して不足分だけ足す
  （他の experimental feature を落とさない）
- `nix config show` 自体が `nix-command` を要求するため、無効な環境では
  `--extra-experimental-features` を一時的に与えて実効値を読む
- macOS の `sudo nix run nix-darwin --` は `env_reset` で `NIX_CONFIG` を失うため
  `sudo_nix` ヘルパ（`sudo env "NIX_CONFIG=..."`）経由にする

なぜ必要か: `--extra-experimental-features` は起動した nix プロセスにしか効かず、
子プロセスへ伝播しない（Nix 2.35 / x86_64-linux で実測）。伝播させないと
bootstrap は `nix run .#switch` の時点で

```
error: experimental Nix feature 'nix-command' is disabled
```

で必ず失敗する。回避できないのは **最も外側の 1 コマンドだけ**
（`nix run` 自体が experimental feature を要求するため）。

```bash
# 初回のみ。2 回目以降は ~/.config/nix/nix.conf が生成されるので普通に実行できる
nix --extra-experimental-features "nix-command flakes" run github:nazozokc/dotfiles
```

`system-manager` は内部の `nix` 呼び出しに自分で
`--extra-experimental-features "nix-command flakes"` を付けるため影響を受けない。

### Neovim プラグイン管理

プラグイン「宣言」は Lua (`nvim/lua/plugins/*.lua`) に残し、プラグイン「実体とバージョン」は Nix が持つ。
正本は **`nvim/nvim-plug-manage/flake.lock` ただ1つ**。

```
nvim/lua/plugins/*.lua                宣言 (lazy-loading / dependencies / opts)
nvim/nvim-plug-manage/sync-inputs.lua 宣言から flake.nix の inputs へ自動同期 (nvim-install が呼ぶ)
nvim/nvim-plug-manage/flake.nix       プラグインの input 一覧 (入力名 = lazy の plugin.name)
nvim/nvim-plug-manage/flake.lock      rev と narHash の正本  ← ここだけ見ればバージョンが分かる
nix/modules/home/programs/nvim/plugins/default.nix
                                      flake.lock から farm (symlink 一覧) を組む
```

- `flake.lock` の `narHash` は `fetchFromGitHub` / `fetchgit` の `outputHash` と一致する
  (NAR ハッシュは tarball を展開して top-level を削った木そのもの。flake の github/git
  fetcher と `fetchFromGitHub`/`fetchgit` で同じ値になる)。よってハッシュを別に管理しない。
- farm は `pkgs.vimUtils.buildVimPlugin` を使わない。`toVimPlugin` が
  `neovimRequireCheckHook` を `preDistPhases` へ足すため、素のソースでは依存プラグイン
  (plenary / nvim-nio / nvim-cmp ...) を require できず失敗する。nixpkgs は
  `overrides.nix` の `dependencies` でそれを埋めているが、lazy.nvim 運用では依存解決は
  Lua 側の仕事なので farm はソースを置くだけでよい。`doc/tags` だけはビルド時に焼く
  (nix store は read-only で、起動後に lazy.nvim から `:helptags` を書けないため)。
- 例外は3件だけ。nixpkgs 側にビルド手順かパッチがあるものは `pkgs.vimPlugins` から取る
  (`plugins/default.nix` の `fromNixpkgs`)。これらは `nvim-plug-manage/flake.nix` には
  入れていない (バージョンは root の nixpkgs input が持つ)。

  | プラグイン                  | 理由                                           |
  | --------------------------- | ---------------------------------------------- |
  | `lazy.nvim`                 | 自身の helptags 生成を消すパッチ               |
  | `denops.vim`                | deno のパスを Nix のものへ焼き込む `postPatch` |
  | `telescope-fzf-native.nvim` | `libfzf.so` を `make` でビルドする             |

- farm のリンク名は lazy.nvim の `plugin.name` (= `flake.nix` の入力名)。
  `init.lua` が `<farm>/<plugin.name>` を `dev.path` として解決するため、
  store の basename や nixpkgs の属性名では絶対に合わない。
- farm は `home.sessionVariables` ではなく `programs.neovim.extraWrapperArgs` の
  `--set LAZY_NIX_PLUGINS` で渡す。`wrapNeovim` が `export` に翻訳するため、
  どのシェルやデスクトップアプリから起動しても必ず効く。
- `init.lua` は `os.getenv("LAZY_NIX_PLUGINS")` を見て `lazy.setup` の
  `dev.path` / `dev.fallback` を組み立てる。未設定なら従来の git clone にフォールバックする。
- `nvim/lazy-lock.json` は farm に全プラグインが入った今は実質不要 (state 配下の
  lockfile の種としてのみ残っている)。`dev.path` が効く限り lazy はgit clone しない。
- lazy.nvim が書き込む lockfile の実体は **state 配下**
  (`~/.local/state/nvim/lazy/lazy-lock.json`)。`~/.config/nvim/lazy-lock.json` は
  `dotfilesDir = self.outPath` 経由の nix store への symlink なので read-only。
  `mkOutOfStoreSymlink` は「activation package に複製しない」だけで store を
  離れるわけではないため、`nix run .#switch` を再実行しても書き可能にはならない。
  `init.lua` が起動時にリポジトリの `nvim/lazy-lock.json` を種としてコピーし、
  既に書き可能な state's 側があればそちらを引き継ぐ。
- プラグインを追加する手順:
  1. `nvim/lua/plugins/*.lua` に宣言を書く (`"owner/repo"` か url 文字列)
  2. `nix run .#nvim-install` で同期と lock → `nix flake check --no-build` → `nix run .#switch`
     (`sync-inputs.lua` が宣言を読み、flake.nix の inputs へ自動追加する。
     手で input を足す必要は無い)
  - nixpkgs に build 手順つきの override があるものだけ `plugins/default.nix` の
    `fromNixpkgs` へ足す (root の nixpkgs input 由来。現状は3件)
  - flake.nix の inputs ブロックは `sync-inputs.lua` が再生成する。
    URL を手で直した場合は保持される (既存優先)。
    Lua から消したプラグインの input は削除されない (orphan 報告のみ)。
- 通常の lazy プラグイン用 `build = "..."` ステップは原則不要。
  `:TSUpdate` のような外部 fetch を行うステップは Nix では機能しないため削除する。
- `nix run .#nvim-update` で全プラグインを更新できる (`nix flake update`)。

### 適用範囲

`nix run .#switch` は OS 検出で適用範囲を決める。

| 環境             | ユーザー層                | OS 層                            |
| ---------------- | ------------------------- | -------------------------------- |
| ネイティブ Linux | home-manager              | system-manager (sudo 必要)       |
| NixOS            | home-manager (`-nixos`)   | nixos-rebuild (sudo 必要)        |
| WSL              | home-manager              | 対象外 (Windows 側 `.wslconfig`) |
| macOS            | home-manager (nix-darwin) | nix-darwin                       |

- 順序は ユーザー層 → OS 層。`sudo` 認証に失敗してもユーザー層は適用済みになる
- WSL は `system-*` の各 app が実行を拒否する（`.wslconfig` の管轄）
- OS 層だけを適用したい場合は `nix run .#system-switch`
- NixOS の判定は `/etc/NIXOS` マーカー (`is_nixos`)。検出すると
  home-manager は `.#<username>-nixos` (nixGL なし版) を、OS 層は
  `nixos-rebuild switch --flake .#<username>` を使う

### NixOS (`nixosConfigurations`)

NixOS ホストは system-manager を使わず、NixOS ネイティブの
`nixosConfigurations` で管理する。

- モジュール: `nix/modules/nixos/` (build / default / system.nix)
- ホスト定義: `nix/hosts/<name>/` (default.nix + hardware-configuration.nix)
  - `hardware-configuration.nix` は実機の disk layout をコミットする。
    初回はスタブ (`/dev/disk/by-label/nixos` / `BOOT`) が入っているので、
    実機で `nixos-generate-config --show-hardware-config` を実行して差し替える
- 適用: `sudo nixos-rebuild switch --flake .#nazozokc`
  (または `nix run .#switch` / `.#system-switch` が自動委譲)
- ユーザー層は standalone home-manager の `homeConfigurations."<username>-nixos"`
  (`mkLinuxHomeConfig { system = "x86_64-linux"; useNixGL = false; }`)。nixGL は不要
  (NixOS の GPU ドライバは `/run/opengl-driver` が正)。`useNixGL = false` で
  nixGL wrap と `targets.genericLinux` が無効になる

**共通化ポリシー** — `nix/modules/system/` のモジュールは
`options.environment.etc.type.getSubOptions [ ] ? replaceExisting` で
system-manager 上かを判定し、両対応している:

| モジュール             | NixOS での扱い                                                                                                |
| ---------------------- | ------------------------------------------------------------------------------------------------------------- |
| `sysctl.nix`           | import 済み。`environment.etc."sysctl.d"` は NixOS でもそのまま動く                                           |
| `input-method.nix`     | import 済み。`replaceExisting` を条件分岐済み                                                                 |
| `locale.nix`           | import 済み。`locale.conf` / `vconsole.conf` / oneshot は NixOS では自動 skip。正は i18n / console モジュール |
| `power.nix`            | **import しない**。NixOS は `services.power-profiles-daemon.enable = true` が正                               |
| `nix-installation.nix` | **import しない**。`system-manager.preActivationAssertions` が NixOS に無く評価エラー                         |

- NixOS の `i18n` モジュールは `imperativeLocale = false` (既定) なら
  `environment.etc."locale.conf".source` を無条件生成する。共有 `locale.nix` の
  `text` 定義とモジュールシステムで衝突するため、共有側は `isSystemManager`
  判定で skip し、NixOS 側は `i18n.defaultLocale` / `console.keyMap` が正
- `programs.fish.enable = true` は必須 (users.users.<name>.shell の検証で要求)
- overlay の `fishPlugins` は `prev.fishPlugins //` で merge すること。
  丸ごと差し替えると `foreign-env` が消え NixOS の `programs.fish.enable` が
  評価エラーになる

### OS 層設定 (system-manager)

ネイティブ Linux の OS 層（`/etc`・systemd システムユニット）は
[numtide/system-manager](https://system-manager.net/main/) で管理する。
macOS 側の nix-darwin に相当する役割。
**NixOS は対象外**（上記「NixOS」参照。`nixos-rebuild` が OS 層を持つ）。
`nix run .#switch` でも適用されるが、単独で実行するコマンド如下。

```bash
# OS 層設定的评价確認
nix run .#system-check

# OS 層設定のビルドのみ
nix run .#system-build

# OS 層設定の適用 (sudo 必要 / WSL では実行不可)
nix run .#system-switch
```

- 対象は **systemd ベースのネイティブ Linux**（Arch / Ubuntu / Debian / Fedora の
  x86_64・aarch64）。WSL では `system-switch` が実行を拒否する。macOS は nix-darwin。
- モジュール構成は全ディストロ共通。プラットフォーム差は `nixpkgs.hostPlatform` のみ。
- 出力は `homeConfigurations` と同じ命名規則:
  - `systemConfigs.nazozokc` → x86_64-linux
  - `systemConfigs.nazozokc-aarch64` → aarch64-linux
- `nix/modules/system/build.nix` が `nixpkgs.hostPlatform` を `system` 引数から注入する。
  `nix flake check` は macOS 上でも両方の設定を評価できる。
- `/etc/nix/nix.conf` は扱わない。`nix/modules/nix-conf.nix` (home-manager) が
  全OSで `~/.config/nix/nix.conf` を生成し、Nix はユーザー設定をシステム設定より
  優先するため、OS 層で上書きする必要がない。
- `system-switch` は属性を flake URI で渡す (`--flake '.#nazozokc'`)。
  `--attr` フラグは存在せず、素の `--flake .` では hostname → `default` の順に
  探索されて `systemConfigs.nazozokc` に到達しない。
- `system-check` / `system-switch` は `nix run <system-manager input>` を使う。
  input は store path に展開されるため、属性なしの installable は Nix 式として
  解釈されて失敗する。`${system-manager}#default` のように属性を付けること。
- system-manager が import する NixOS モジュールには `boot` / `config/sysctl.nix` /
  `i18n.defaultLocale` / `services.networking.udev.nix` が含まれない。
  `boot.kernel.sysctl` は silent no-op、`i18n.defaultLocale` も使えないため、
  sysctl と locale は `environment.etc` と自作 systemd oneshot で実装する。
- `locale.nix` は `locale-gen` の絶対パスを順に探す (`/usr/bin` → `/usr/sbin`)。
  Arch は前者、Debian / Ubuntu は後者に置くため。
  どちらも無いディストリ (Alpine 等) では `localedef` で候補 trieset を生成する。
- ディストリ判定は `system-manager.allowAnyDistro = true` で無効化している
  (既定の許可リストは nixos / ubuntu / debian のみ)。
- `power.nix` は power-profiles-daemon と競合する power 管理 service
  (`auto-cpufreq` / `system76-power` / `tuned` / `tlp`) を mask する。
  PPD 单元の `Conflicts=` とPackages 側を突き合わせて決めた。
- Nix の導入モードはホストごとに違うので `dotfiles.system.nixStoreAccess` で宣言する
  (`nix/modules/system/nix-installation.nix`、既定は `daemon`)。

  | 値       | 導入方法                                                                                           | userborn への宣言                       |
  | -------- | -------------------------------------------------------------------------------------------------- | --------------------------------------- |
  | `daemon` | multi-user (`--daemon` / `apt install nix` / `dnf install nix`)。`nix-daemon` が build user を管理 | 宣言しない。build user を壊さない       |
  | `nixbld` | 旧 installer の single-user。`/nix/store` が `root:nixbld 1775`                                    | `nixbld` の member に実行ユーザーを追加 |
  | `user`   | 新 installer の single-user。`/nix/store` が実行ユーザー所有、`nixbld` グループ自体が無い          | 宣言しない                              |

  `daemon` モードで `nixbld` への所属を宣言すると、userborn が実行ユーザーを
  `nixbld` へ追加し、`nix-daemon` を迂回して store を直接書けるようになる
  (権限の降格)。逆に `nixbld` モードを宣言し損れると store へ書けなくなる。
  宣言だけでは実モードが見えないので、`system-switch` の
  `preActivationAssertions` が daemon socket・store の所有者・`/etc/group` を
  読んで実モードと突き合わせる。宣言 `nixbld` なのに実ホストが別なら権限の降格
  になるため中断、それ以外のずれは warning のみ
  (1 リポジトリを複数ホストで共有するため)。

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
flake.nix                                 # 配線のみ (inputs / imports / 設定の属性)
├── nix/lib/identity.nix                  # username・repoOwner
├── pkgsFor (nix/lib/pkgs.nix)            → nixpkgs インスタンス生成 (Intelスタック切替)
├── imports → nix/flake-parts/            # devShells と apps (nix run .#*)
│   └── apps/common.nix                   # identity / shell.nix / targets.nix / system-manager input
├── Linux:   mkLinuxHomeConfig (nix/modules/linux/build.nix)
│              → nix/modules/home/      + nix/modules/linux/
│              (useNixGL = false で NixOS 用 home に切替)
│           systemConfigs.{nazozokc,nazozokc-aarch64} (system-manager)
│              → mkSystemConfig (nix/modules/system/build.nix)
│                 → nix/modules/system/  (OS 層: /etc・systemd システムユニット)
├── NixOS:   nixosConfigurations.nazozokc
│              → mkNixosConfig (nix/modules/nixos/build.nix)
│                 → nix/modules/nixos/ + nix/modules/system/ (共有 3 モジュール)
│                 → nix/hosts/nazozokc/  (hardware-configuration + boot.loader)
├── WSL:     mkWSLHomeConfig (nix/modules/wsl/build.nix)
│              → nix/modules/home/wsl.nix + nix/modules/wsl/
└── macOS:   mkDarwinConfig (nix/modules/macos/build.nix)
               → nix/modules/macos/     + nix/modules/home/ (via nix-darwin)
```

- `flake.nix` は「どのファイルを import するか」だけを持つ。app のスクリプトや
  シェルヘルパは `flake.nix` に書かない
- `programs-common.nix` が共通の program モジュールを一括 import する
- `dotfiles-link.nix` が共有ファイルの symlink を一括管理する
- `packages/default.nix` がカテゴリ別パッケージを flatten して `home.packages` に渡す
- Linux は `nixGL` で wezterm/ghostty/zen-browser をラップして非 NixOS 環境の GPU
  ライブラリに対応
- Zen Browser は nixpkgs に無いため `github:youwen5/zen-browser-flake` の input を使う。
  この flake は x86_64-linux / aarch64-linux のみ提供するので、
  パッケージの解決は `nix/modules/linux/build.nix` に置いた `zenBrowser`
  （= `zen-browser.packages.${system}.zen-browser`）経由で `extraSpecialArgs` に渡す。
  WSL / macOS は input を受け取らない
- `nix/lib/targets.nix` が attr 名の付け方を持つ。`homeConfigurations.<username>` /
  `darwinConfigurations.<username-x86_64>` / `systemConfigs.<username>` や
  `nix build .#...` の対象はすべてここを通る

## username の決定

- 単一ソース: `nix/lib/identity.nix` の `username`（`flake.nix` が import して
  `nix/lib/targets.nix` 経由で attr 名と `nix/shared.nix` に渡す）
- ローカルユーザー名として使う。clone 先の ghq パスは同じファイルの
  `repoOwner` を使うので、別のユーザーで運用しても clone 先は変わらない
- 影響範囲:
  - `homeConfigurations.<username>` / `darwinConfigurations.<username>` / `systemConfigs.<username>` の attr 名
  - `nix/shared.nix` 経由で `home.username` / `home.homeDirectory` / `DOTFILES_USERNAME`
  - `switch` app が WSL 向けに渡す `.#<username>-wsl`
- **flake の `outputs` 内では環境変数・`whoami` を使わない。** pure 評価なので
  実行環境に依存する手段が使えない（Nix 2.35 で実測）:
  - `builtins.getEnv "USER"` はエラーにならず `""` を返すだけ
  - `builtins.currentUser` は builtins に存在しない
  - impure 評価を採ると `nix flake check` / `nix run .#switch` / home-manager 起動の
    全部に `--impure` を伝播させる必要があり、CI 品質ゲートが壊れる
  - 代替として `apps.default`（bootstrap）が実行時に `id -un` を取得し、
    clone 先リポジトリの `nix/lib/identity.nix` の `username` を書き換える
    （値が同じなら触らない）。`repoOwner` は触らない
  - 手作業で変える場合も `nix/lib/identity.nix` だけを編集する。
    `username` を読むのはこの1箇所だけ

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
- **参考になりそう**: <https://github.com/ntsk/dotfiles>

## 運用ポリシー

### CI品質ゲート

- PR の必須チェックは `nix flake check`（Linux / macOS 両方で実行）。
  - `flake check` には deadnix / statix / shellcheck / typos / treefmt の各チェックも含まれます。
- 補助チェックとして個別に実行する場合は以下のようにします。

```bash
nix build .#checks.x86_64-linux.typos --print-build-logs
nix build .#checks.x86_64-linux.deadnix .#checks.x86_64-linux.statix .#checks.x86_64-linux.shellcheck --print-build-logs
```

### sops-nix シークレット運用

- 暗号化ファイルは `secrets/common.yaml` を使用する。
- home-manager の展開先:
  - `api/github_token` → `~/.config/secrets/github_token`
  - `api/openai_api_key` → `~/.config/secrets/openai_api_key`
  - `api/anthropic_api_key` → `~/.config/secrets/anthropic_api_key`
- AGE鍵は `~/.config/sops/age/keys.txt`。
- `secrets/common.yaml` がない環境では secret を読まない（復号不要のCIを壊さないため）。
