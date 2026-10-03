# Wiki

[![DeepWiki](https://img.shields.io/badge/DeepWiki-nazozokc%2Fdotfiles-blue.svg?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACwAAAAyCAYAAAAnWDnqAAAAAXNSR0IArs4c6QAAA05JREFUaEPtmUtyEzEQhtWTQyQLHNak2AB7ZnyXZMEjXMGeK/AIi+QuHrMnbChYY7MIh8g01fJoopFb0uhhEqqcbWTp06/uv1saEDv4O3n3dV60RfP947Mm9/SQc0ICFQgzfc4CYZoTPAswgSJCCUJUnAAoRHOAUOcATwbmVLWdGoH//PB8mnKqScAhsD0kYP3j/Yt5LPQe2KvcXmGvRHcDnpxfL2zOYJ1mFwrryWTz0advv1Ut4CJgf5uhDuDj5eUcAUoahrdY/56ebRWeraTjMt/00Sh3UDtjgHtQNHwcRGOC98BJEAEymycmYcWwOprTgcB6VZ5JK5TAJ+fXGLBm3FDAmn6oPPjR4rKCAoJCal2eAiQp2x0vxTPB3ALO2CRkwmDy5WohzBDwSEFKRwPbknEggCPB/imwrycgxX2NzoMCHhPkDwqYMr9tRcP5qNrMZHkVnOjRMWwLCcr8ohBVb1OMjxLwGCvjTikrsBOiA6fNyCrm8V1rP93iVPpwaE+gO0SsWmPiXB+jikdf6SizrT5qKasx5j8ABbHpFTx+vFXp9EnYQmLx02h1QTTrl6eDqxLnGjporxl3NL3agEvXdT0WmEost648sQOYAeJS9Q7bfUVoMGnjo4AZdUMQku50McDcMWcBPvr0SzbTAFDfvJqwLzgxwATnCgnp4wDl6Aa+Ax283gghmj+vj7feE2KBBRMW3FzOpLOADl0Isb5587h/U4gGvkt5v60Z1VLG8BhYjbzRwyQZemwAd6cCR5/XFWLYZRIMpX39AR0tjaGGiGzLVyhse5C9RKC6ai42ppWPKiBagOvaYk8lO7DajerabOZP46Lby5wKjw1HCRx7p9sVMOWGzb/vA1hwiWc6jm3MvQDTogQkiqIhJV0nBQBTU+3okKCFDy9WwferkHjtxib7t3xIUQtHxnIwtx4mpg26/HfwVNVDb4oI9RHmx5WGelRVlrtiw43zboCLaxv46AZeB3IlTkwouebTr1y2NjSpHz68WNFjHvupy3q8TFn3Hos2IAk4Ju5dCo8B3wP7VPr/FGaKiG+T+v+TQqIrOqMTL1VdWV1DdmcbO8KXBz6esmYWYKPwDL5b5FA1a0hwapHiom0r/cKaoqr+27/XcrS5UwSMbQAAAABJRU5ErkJggg==)](https://deepwiki.com/nazozokc/dotfiles)

# Nazozo Dotfiles

このリポジトリは Linux / macOS / WSL の dotfiles 管理を行う構成です。

- **Linux / macOS / WSL**: Nix + Home Manager で管理
- **設定ファイルは可能な限り共通化**: `nvim/`, `wezterm/`, `opencode/`, `efm-langserver/` は全OSで同一ファイルを共有。`git` / `starship` / `lazygit` / `bat` は Nix が `nix/modules/home/programs/<name>/` から生成する（リポジトリにはディレクトリを置かない）

---

## 対応 OS

- Linux: `x86_64-linux` (systemd ベースのディストリ。Arch Linux / Ubuntu / Debian / Fedora など)
- Linux: `aarch64-linux` (ARM linux)
- WSL: `x86_64-linux` (WSL2)
- macOS: `aarch64-darwin` (Apple Silicon) / `x86_64-darwin` (Intel Mac)

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

## 初回導入 (bootstrap)

`/etc/nix/nix.conf` を手書きする必要はありません。
`nix.conf` は `switch` 実行時に home-manager が `~/.config/nix/nix.conf` として生成します。
Nix はユーザー設定をシステム設定より優先するため、初期状態で機能します。

```bash
# ghq へ clone して、そのまま自動で switch まで行う
nix run github:nazozokc/dotfiles
```

- リポジトリは `~/ghq/github.com/nazozokc/dotfiles` に配置され、続けて自動で `switch` されます
  - clone 先はリポジトリ所有者で決まるので、ローカルユーザー名が変わっても配置先は同じです
- ユーザー名は bootstrap が `id -un` から取得し、`nix/lib/identity.nix` の
  `username` に自動設定します
  （値が同じなら変更しません / 設定を変えた場合は `commit` してください）
- 既にクローン済みなら `git remote update`（fetch のみ）となり、ローカルの HEAD がそのまま適用されます
  - HEAD・ブランチは一切変更しません
- クローン先は環境変数 `GHQ_ROOT` で変更できます（既定 `~/ghq`）
- ghq / git がまだ無い環境では git にフォールバックするため、Nix だけで bootstrap できます
- Linux の OS 層（`/etc`・systemd システムユニット）も `switch` が適用します（sudo 必要 / WSL は対象外）。
  OS 層だけを適用する場合は `nix run github:nazozokc/dotfiles#system-switch`

初回のみ `nix.conf` が未生成なので、**一番外側のコマンドだけ** `nix-command` を
コマンドラインで明示する必要があります（`nix run` 自体が experimental feature を
要求するため、ここだけは回避できません）。

```bash
nix --extra-experimental-features "nix-command flakes" run github:nazozokc/dotfiles
```

- このフラグは**その 1 プロセスにしか効きません**。`--extra-experimental-features` は
  子プロセス（app 内の `nix flake check` / `nix run .#switch` / home-manager が
  内部で起動する `nix`）へ伝播せず、そのままでは bootstrap が 2 段目で
  `error: experimental Nix feature 'nix-command' is disabled` で止まります
- そのため全 app は起動時に `NIX_CONFIG`（プロセス環境なので子・孫へ継承される）
  で不足している feature を補うので、**フラグは最も外側のコマンドだけで十分**です
- 既に `nix-command` / `flakes` が有効な環境では `NIX_CONFIG` を一切変更しません。
  他の experimental feature を含む値もそのまま引き継ぎます
- この flake は `nixConfig` を定義していないので `--accept-flake-config` は不要です
- `switch` が完了すると `~/.config/nix/nix.conf` が生成され、以降は
  `nix run .#switch` だけで適用できます

### 手動でリポジトリを管理する場合

bootstrap を経由せず自分で管理したい場合はこちらでも導入できます。

```bash
git clone https://github.com/nazozokc/dotfiles.git ~/ghq/github.com/nazozokc/dotfiles
cd ~/ghq/github.com/nazozokc/dotfiles
nix run .#switch
```

- 初回は `nix.conf` が未生成なので `nix-command` をコマンドラインで明示する
  （上のように最も外側のコマンドだけ）
- `switch` が完了すると `~/.config/nix/nix.conf` が生成され、
  以降は `nix run .#switch` だけで適用できる
- Linux / macOS 両方で同じコマンドで初回セットアップ可能
- Home Manager による dotfiles のリンクとパッケージインストールが行われます
- macOS では nix-darwin を通して Home Manager 設定も有効化されます

---

## 通常の更新・再適用

```bash
# 手元のリポジトリを fetch してから切り替える
nix run github:nazozokc/dotfiles

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

## WSL セットアップ

WSL の設定は次の 2 ファイルで管理します。配置先が異なるため注意してください。

| ファイル         | 配置先                               | スコープ                    | 管理方法                         |
| ---------------- | ------------------------------------ | --------------------------- | -------------------------------- |
| `wsl/.wslconfig` | Windows側 `%USERPROFILE%\.wslconfig` | **全ディストロ共通** (WSL2) | 手動コピー                       |
| `wsl/wsl.conf`   | ディストロ内 `/etc/wsl.conf`         | ディストロ別                | `my_scripts/wsl-setup.sh` (root) |

### `.wslconfig` — 全ディストロ共通 (Windows側)

`.wslconfig` は WSL の **Linux 側 `~/.wslconfig` では読まれない**ため、必ず Windows 側に配置してください。

```powershell
# Windows 側で手動コピー
cp wsl/.wslconfig $env:USERPROFILE\.wslconfig
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

## `~/.scripts` — 手書きの補助スクリプト

`my_scripts/` は `~/.scripts` へ symlink される。PATH には載らないので
`~/.scripts/<name>.sh` で直接呼ぶ。

| スクリプト      | 用途                                                        |
| --------------- | ----------------------------------------------------------- |
| `wsl-setup.sh`  | `/etc/wsl.conf` 反映 + `ja_JP.UTF-8` 生成（`sudo` 必須）    |
| `extract.sh`    | アーカイブ自動判別で展開（tar / zip / 7z / deb / rpm など） |
| `gh-new.sh`     | GitHub リポジトリを作って clone して cd                     |
| `gh-pr.sh`      | PR 作成と `--web` 表示                                      |
| `mkcd.sh`       | ディレクトリ作成して cd                                     |
| `port-check.sh` | 待ち受けポートとプロセスの表示（`ss` / `lsof`）             |

更新・ビルド・プラグイン更新は `nix run .#switch` / `.#build` / `.#update` / `.#lazy2nix` が持ち、
Nix store の GC は systemd ユーザタイマー (`nix-store-gc`) が週1で実行する。
この領域を shell スクリプトで再実装しない。

---

## 管理対象一覧

- **シェル**: fish, zsh, bash
- **エディタ**: Neovim, VSCode
- **プロンプト**: starship
- **CLIツール**: Nix によるパッケージ管理。`nix/modules/home/packages/` 配下で分類 (`base/`, `dev/`, `ai/`, `gui/`, `experimental/`)
  - **base**: jq, curl, zoxide, fd, eza, tmux, yazi, gh, ghq, jujutsu, docker, lazydocker, nix-tree, cachix, nh など
  - **dev**: nodejs_latest, bun, deno, rustc, go, jdk, clang, efm-langserver など
  - **ai**: ollama, opencode, codex, claude-code
  - **gui**: wezterm, ghostty, vscode, spotify, discord, google-chrome など
  - **experimental**: pi-coding-agent, grok-cli, qwen-code
  - **Linux / WSL 共通**は `nix/lib/packages/shared.nix`（クリップボード / アーカイブ / nmap / fontconfig / gnupg / openssh / XDG / herdr）
- **Home Manager**: dotfiles (`.config/*`), ホームディレクトリリンク管理
- **Linux GUI (Hyprland)**: Ambxst (Quickshell 製シェル。bar / launcher / 通知 / ロック / 壁紙 / スクリーンショット / メディア / OSD を統合) + `hypr/` の設定
- **macOS限定**: nix-darwin によるシステム設定

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

## ユーザー名

- ユーザー名の単一ソースは **`nix/lib/identity.nix`** の `username` です。
- 同じファイルの `repoOwner` が clone 先（`~/ghq/github.com/<repoOwner>/dotfiles`）を
  決めるので、ユーザー名を変えても clone 先は独立しています。
- bootstrap（`nix run github:nazozokc/dotfiles`）は `id -un` から
  clone 先リポジトリの `nix/lib/identity.nix` の `username` を書き換えます
  （`repoOwner` とコメントは残す）。値が同じなら触りません。
- 手作業でユーザー名を変える場合も `nix/lib/identity.nix` だけを編集してください。
- flake の `outputs` 内では環境変数を参照しません。pure 評価なので
  `builtins.getEnv` は空文字を返すだけで、`builtins.currentUser` は Nix 2.35 に存在しません。
  詳細は [`nix/README.md`](./nix/README.md) の「username の決定」を参照。

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
