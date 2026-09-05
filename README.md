# Wiki

[![DeepWiki](https://img.shields.io/badge/DeepWiki-nazozokc%2Fdotfiles-blue.svg?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACwAAAAyCAYAAAAnWDnqAAAAAXNSR0IArs4c6QAAA05JREFUaEPtmUtyEzEQhtWTQyQLHNak2AB7ZnyXZMEjXMGeK/AIi+QuHrMnbChYY7MIh8g01fJoopFb0uhhEqqcbWTp06/uv1saEDv4O3n3dV60RfP947Mm9/SQc0ICFQgzfc4CYZoTPAswgSJCCUJUnAAoRHOAUOcATwbmVLWdGoH//PB8mnKqScAhsD0kYP3j/Yt5LPQe2KvcXmGvRHcDnpxfL2zOYJ1mFwrryWTz0advv1Ut4CJgf5uhDuDj5eUcAUoahrdY/56ebRWeraTjMt/00Sh3UDtjgHtQNHwcRGOC98BJEAEymycmYcWwOprTgcB6VZ5JK5TAJ+fXGLBm3FDAmn6oPPjR4rKCAoJCal2eAiQp2x0vxTPB3ALO2CRkwmDy5WohzBDwSEFKRwPbknEggCPB/imwrycgxX2NzoMCHhPkDwqYMr9tRcP5qNrMZHkVnOjRMWwLCcr8ohBVb1OMjxLwGCvjTikrsBOiA6fNyCrm8V1rP93iVPpwaE+gO0SsWmPiXB+jikdf6SizrT5qKasx5j8ABbHpFTx+vFXp9EnYQmLx02h1QTTrl6eDqxLnGjporxl3NL3agEvXdT0WmEost648sQOYAeJS9Q7bfUVoMGnjo4AZdUMQku50McDcMWcBPvr0SzbTAFDfvJqwLzgxwATnCgnp4wDl6Aa+Ax283gghmj+vj7feE2KBBRMW3FzOpLOADl0Isb5587h/U4gGvkt5v60Z1VLG8BhYjbzRwyQZemwAd6cCR5/XFWLYZRIMpX39AR0tjaGGiGzLVyhse5C9RKC6ai42ppWPKiBagOvaYk8lO7DajerabOZP46Lby5wKjw1HCRx7p9sVMOWGzb/vA1hwiWc6jm3MvQDTogQkiqIhJV0nBQBTU+3okKCFDy9WwferkHjtxib7t3xIUQtHxnIwtx4mpg26/HfwVNVDb4oI9RHmx5WGelRVlrtiw43zboCLaxv46AZeB3IlTkwouebTr1y2NjSpHz68WNFjHvupy3q8TFn3Hos2IAk4Ju5dCo8B3wP7VPr/FGaKiG+T+v+TQqIrOqMTL1VdWV1DdmcbO8KXBz6esmYWYKPwDL5b5FA1a0hwapHiom0r/cKaoqr+27/XcrS5UwSMbQAAAABJRU5ErkJggg==)](https://deepwiki.com/nazozokc/dotfiles)

# Nazozo Dotfiles

このリポジトリは Linux / macOS / Windows (native) の3OS対応で dotfiles 管理を行う構成です。

- **Linux / macOS / WSL**: Nix + Home Manager で管理
- **Windows (native)**: PowerShell 7 スクリプトで管理
- **設定ファイルは可能な限り共通化**: `git/`, `starship/`, `lazygit/`, `bat/`, `nvim/`, `wezterm/`, `opencode/`, `efm-langserver/` は全OSで同一ファイルを共有

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
- Linux: `aarch64-linux` (ARM linux)
- WSL: `x86_64-linux` (WSL2)
- macOS: `aarch64-darwin` (Apple Silicon) / `x86_64-darwin` (Intel Mac)
- Windows: native (PowerShell 7 + scoop/winget)

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

# nix.conf が存在しない or experimental-features が未設定の場合のセットアップ
sudo mkdir -p /etc/nix
sudo tee /etc/nix/nix.conf > /dev/null << 'EOF'
experimental-features = nix-command flakes
build-users-group = nixbld
trusted-users = root nazozokc
EOF

# nix.conf 書き込み後はシェルを再起動するか、以下で即座に反映可能
exec $SHELL

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

---

## Windows セットアップ (ネイティブ)

### 前提条件

- Windows 10 22H2+ または Windows 11
- [PowerShell 7](https://github.com/PowerShell/PowerShell) (`winget install Microsoft.PowerShell`)
- 管理者権限は不要（scoop はユーザー権限で動作）

### インストール手順

```powershell
# 1. リポジトリをクローン
cd ~
git clone https://github.com/nazozokc/dotfiles.git
cd dotfiles

# 2. セットアップスクリプトを実行
pwsh -ExecutionPolicy RemoteSigned -File windows/setup.ps1
```

スクリプトは `windows/apply.ps1` を呼び出し、`windows/config.psd1` を読んで収束（Nix の `nix run .#switch` に相当）します：

1. **パッケージ** のインストール（scoop / winget / PSGallery で neovim, git, starship, lazygit, wezterm など）
2. **設定ファイルの symlink**（`git/`, `starship/`, `lazygit/`, `bat/`, `nvim/`, `wezterm/` など → Windows の適切なパス）
3. **PowerShell プロファイル** のインストール（PS7 + PS5 両対応）
4. **システム設定**（レジストリ調整）

### セットアップ後にやること

```powershell
# PowerShell 7 を再起動（プロファイルを読み込む）
# または手動で読み込み
. $PROFILE
```

- Windows Terminal の設定は `windows/terminal/settings.json` を参照して手動で適用してください
- フォントは JetBrainsMono Nerd Font が自動インストールされます

### パッケージ更新

```powershell
# dotfiles の収束を再適用
pwsh windows/apply.ps1

# scoop 全更新
scoop update && scoop update *

# winget 更新
winget upgrade --all
```

### 設定ファイルの構成

```
dotfiles/
├── git/                          # Linux/macOS/WSL/Windows で共有
│   ├── config                    #   メイン設定
│   ├── aliases                   #   Git エイリアス
│   └── ignore                    #   グローバル gitignore
├── starship/starship.toml        # 全OS共有
├── lazygit/config.yml            # 全OS共有
├── bat/config                    # 全OS共有
├── nvim/                         # 全OS共有
├── wezterm/                      # 全OS共有
├── opencode/                     # 全OS共有 (エージェント設定)
├── efm-langserver/config.yaml    # 全OS共有
├── windows/                      # Windows 専用
│   ├── setup.ps1                 #   セットアップエントリポイント
│   ├── apply.ps1                 #   収束メイン (Nix 相当)
│   ├── config.psd1               #   宣言的所望状態
│   ├── modules/                  #   PackageManager / SymlinkManager / ProfileManager / SystemManager
│   ├── Microsoft.PowerShell_profile.ps1  # PowerShell 7 プロファイル
│   └── terminal/settings.json    #   Windows Terminal 設定（参考）
├── wsl/                          # WSL 専用
│   ├── .wslconfig                #   全ディストロ共通 (Windows側 %USERPROFILE%\.wslconfig へ symlink)
│   └── wsl.conf                  #   ディストロ別 (/etc/wsl.conf へ wsl-setup.sh で配置)
├── nix/                          # Linux/macOS/WSL 専用 (Nix)
├── hypr/ waybar/ rofi/ dunst/    # Linux GUI (Hyprland) 専用
├── fish/ / zsh/ / bash/          # Linux/macOS/WSL 専用
└── my_scripts/                   # 自作運用スクリプト
```

### 注意事項

- **fish / zsh / tmux / ghostty / Hyprland** は Windows では動作しないため対象外です
- **sops-nix** によるシークレット管理は Windows 未対応です
- Windows Terminal の `settings.json` はマシン固有の GUID が含まれるため、参考値として提供しています

---

## WSL セットアップ

WSL の設定は次の 2 ファイルで管理します。配置先が異なるため注意してください。

| ファイル         | 配置先                               | スコープ                    | 管理方法                         |
| ---------------- | ------------------------------------ | --------------------------- | -------------------------------- |
| `wsl/.wslconfig` | Windows側 `%USERPROFILE%\.wslconfig` | **全ディストロ共通** (WSL2) | `windows/apply.ps1` が symlink   |
| `wsl/wsl.conf`   | ディストロ内 `/etc/wsl.conf`         | ディストロ別                | `my_scripts/wsl-setup.sh` (root) |

### `.wslconfig` — 全ディストロ共通 (Windows側)

`wsl/.wslconfig` が `%USERPROFILE%\.wslconfig` への symlink として管理されます。
`.wslconfig` は WSL の **Linux 側 `~/.wslconfig` では読まれない**ため、必ず Windows 側に配置してください。

```powershell
# Windows 側でリポジトリの apply.ps1 を実行 (symlink 作成・更新)
pwsh windows/apply.ps1
```

主な設定:

- `memory=8GB` / `processors=8` / `swap=4GB` — vmmem がホスト RAM を食い尽くすのを防止
- `networkingMode=mirrored` — localhost 共有 / IPv6 / ホスト IP 到達性
- `dnsTunneling=true` — VPN・社内 NW で `resolv.conf` が壊れる問題を防止
- `autoMemoryReclaim=gradual` + `sparseVhd=true` — メモリ・VHD の無制限膨張を防止
- `defaultVhdSize=256GB` — ディスク上限 (既存 VHD に効かせるには `wsl --manage <distro> --set-sparse true`)

### `/etc/wsl.conf` — ディストロ別 (root 必要)

```bash
# リポジトリの wsl/wsl.conf を /etc/wsl.conf に反映 + ja_JP.UTF-8 ロケール生成
sudo ~/.scripts/wsl-setup.sh
```

主な設定:

- `[boot] systemd=true` — home-manager の systemd タイマー (nix-store GC 等) に必須
- `[automount] options="metadata,umask=22,fmask=11"` — /mnt/c の権限メタデータ保持
- `[network] generateResolvConf=true` — DNS 自動生成 (VPN で壊れる場合は `false` にして手動管理)
- `[user] default=nazozokc` / `[time] useWindowsTimezone=true`

### 設定変更後の反映

```powershell
# Windows 側で実行: 全 WSL を停止して 8 秒待ってから再起動
wsl --shutdown
```

- 設定は WSL インスタンス完全停止後に読み込まれます (8秒ルール)
- 複数ディストロがある場合、`/etc/wsl.conf` は各ディストロで `wsl-setup.sh` を実行してください (`.wslconfig` は全ディストロに自動適用されます)
- `nix run .#switch` (WSL) は実行前に `.wslconfig` の symlink 状態を事前チェックします

---

## 管理対象一覧

- **シェル**: fish, zsh, bash
- **エディタ**: Neovim, VSCode, Zed
- **プロンプト**: starship
- **CLIツール**: Nix によるパッケージ管理。`nix/modules/home/packages/` 配下で分類 (`base/`, `dev/`, `ai/`, `gui/`, `experimental/`)
  - **base**: jq, curl, zoxide, eza, tmux, yazi, gh, ghq, jujutsu, docker, lazydocker, nix-tree, cachix, nh など
  - **dev**: python312, nodejs, bun, deno, rustc, go, jdk, clang, efm-langserver など
  - **ai**: ollama, opencode, codex, claude-code
  - **gui**: wezterm, ghostty, vscode, zed, spotify, discord, google-chrome など
  - **experimental**: pi-coding-agent, grok-cli, qwen-code
- **Home Manager**: dotfiles (`.config/*`), ホームディレクトリリンク管理
- **Linux GUI (Hyprland)**: hypr, waybar, rofi, dunst
- **macOS限定**: nix-darwin によるシステム設定
- **Windows限定**: PowerShell 7 スクリプト (`windows/`) による収束管理

---

## 注意事項

- OS本体やカーネルは pacman（Linux）や macOS 標準管理に任せる
- Home Manager によるリンクや設定は既存の dotfiles を上書きする場合があります

## 運用ルール（品質ゲート）

- PR では **Nix Flake Check**（`nix flake check`）と **treefmt check**（`nix fmt -- --ci`）を必須とします。
- ローカルでも PR 前に次を実行してください。

```bash
nix flake check
nix fmt -- --ci
```

## シークレット管理（sops-nix）

- シークレットは `secrets/common.yaml` を **sops で暗号化**して管理します。
- 展開先（Linux / WSL）は以下です。
  - `api/github_token` → `~/.config/secrets/github_token`
  - `api/openai_api_key` → `~/.config/secrets/openai_api_key`
  - `api/anthropic_api_key` → `~/.config/secrets/anthropic_api_key`
- 鍵は `~/.config/sops/age/keys.txt` を使用します。
- `secrets/common.yaml` が存在しない場合、secret は読み込まれません（CIの非復号チェックを壊さないため）。

## home.stateVersion ポリシー

- 現在値は `nix/shared.nix` の `home.stateVersion = "26.11";`。
- 互換性維持のため、**通常運用で上げない**。
- 上げるのは以下を満たす場合のみ。
  1. Home Manager / nixpkgs 更新で新規 stateVersion が必要。
  2. 変更PRで `nix flake check` と `nix run .#build` を通過。
  3. 既存dotfilesリンク・シェル起動・主要CLI（git, gh, nvim）動作確認を記録。
- 例外: Intel Mac (`x86_64-darwin`) は home-manager 26.05 系スタックのため `mkForce "26.05"` に固定。

# Activity

![Alt](https://repobeats.axiom.co/api/embed/c4db566c918002010974abbbcc1ee5150bed51da.svg "Repobeats analytics image")

# LICENSE

MIT
