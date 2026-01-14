# dotfiles

このリポジトリは `git clone` → **シンボリックリンク** で各設定を適用する運用を前提としています。

管理対象:

- `nvim`
- `fish`
- `zsh`
- `wezterm`
- `nix`

---

## 前提

- リポジトリは `~/dotfiles` にクローンすることを想定しています（変更可）。
- 既存の設定は必ず**バックアップ**するか削除してから適用してください。
- 設定は **コピーではなく symlink** で管理します。コピーは混乱の元。

---

## 1. リポジトリをクローン

```bash
cd ~
git clone https://github.com/ユーザー名/dotfiles.git
# もしくは SSH
# git clone git@github.com:ユーザー名/dotfiles.git
```

必要なら `DOTFILES` 変数を書き換えてください。

---

## 2. 手動でシンボリックリンクを作る（安全）

以下は `~/dotfiles` を前提とした例。

### nvim

```bash
rm -rf ~/.config/nvim
ln -sfn ~/dotfiles/nvim ~/.config/nvim
```

### fish

```bash
rm -rf ~/.config/fish
ln -sfn ~/dotfiles/fish ~/.config/fish
```

### zsh

*`.zshrc` 単体管理なら*:

```bash
rm -f ~/.zshrc
ln -sfn ~/dotfiles/zsh/.zshrc ~/.zshrc
```

*ディレクトリで管理するなら（おすすめ）*:

```bash
# ~/.config/zsh にまとめる場合
rm -rf ~/.config/zsh
ln -sfn ~/dotfiles/zsh ~/.config/zsh
# ~/.zshrc の冒頭に入れる（ZDOTDIR を使う場合）
# export ZDOTDIR="$HOME/.config/zsh"
```

### wezterm

```bash
rm -f ~/.wezterm.lua
ln -sfn ~/dotfiles/wezterm/.wezterm.lua ~/.wezterm.lua
```

### nix

通常の `~/.config/nix` を使う場合:

```bash
rm -rf ~/.config/nix
ln -sfn ~/dotfiles/nix ~/.config/nix
```

**NixOS の場合** ` /etc/nixos` に置く必要があるなら sudo が必要です（注意して実行）。

```bash
# NixOS の場合の例（慎重に）
sudo mv /etc/nixos /etc/nixos.backup || true
sudo ln -sfn /home/ユーザー名/dotfiles/nix /etc/nixos
```

---

## 3. 自動インストールスクリプト（例）

リポジトリに `install.sh` を置くと便利。以下はシンプルなサンプル。

```bash
#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/dotfiles"

# 各シンボリックリンク（上書き可）
ln -sfn "$DOTFILES/nvim" "$HOME/.config/nvim"
ln -sfn "$DOTFILES/fish" "$HOME/.config/fish"
ln -sfn "$DOTFILES/zsh" "$HOME/.config/zsh"
ln -sfn "$DOTFILES/wezterm/.wezterm.lua" "$HOME/.wezterm.lua"
ln -sfn "$DOTFILES/nix" "$HOME/.config/nix"

echo "dotfiles applied"
```

実行前に `chmod +x install.sh` を忘れずに。

---

## 4. 反映確認

各アプリを起動して問題がないか確認。

```bash
nvim --version
fish --version
zsh --version
wezterm --version
# Nix の場合は環境に応じて確認
```

リンク先の確認:

```bash
ls -l ~/.config/nvim
ls -l ~/.config/fish
ls -l ~/.zshrc
ls -l ~/.wezterm.lua
```

---

## 5. 注意点 & トラブルシュート

- **必ずバックアップ**: 既存設定を上書きする前に `mv` で退避しておけ。
- NixOS の `/etc/nixos` を弄るとシステム設定に影響する。慎重に。
- `wezterm` の設定ファイル名やパスを変えている場合は適宜読み替え。
- もし動作しないなら、まず `ls -l` で symlink の向き先を確認する。

---

## 6. マルチマシン運用のヒント

- ホスト固有の差分は `hosts/` ディレクトリや `local` ファイルで分ける（.gitignoreに入れる）。
- `chezmoi` や `stow` を使うと環境ごとの分岐運用が楽になる。

---

## ライセンス

必要ならここにライセンス（例: MIT）を記載してください。

---

以上。問題なければこの README をそのまま `README.md` として置け。必要なら細かくカスタムしてやる。

****
