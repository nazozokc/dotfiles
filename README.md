# dotfiles

Linux 向けのnazozokc個人用 dotfiles 管理リポジトリ。  
主に **開発環境・シェル・エディタ・ターミナル設定**を一元管理する目的で運用している。

> ⚠️ 個人環境前提のため、そのままの利用は非推奨  
> 必要な部分だけ参考にする用途を想定

---

## 対象環境

| 項目 | 内容 |
|---|---|
| OS | Arch Linux |
| Shell | fish / (zsh)|
| Editor | Neovim |
| Terminal | WezTerm |
| Package | pacman / yay / nix（試験的） |

※ macOS / Windows は未対応  
※ Arch 以外では一部設定が動作しない可能性あり

---

## ディレクトリ構成

```text
.
├── fish/        # fish shell 設定
├── zsh/         # zsh 設定
├── nvim/        # Neovim 設定
├── wezterm/     # WezTerm 設定
├── nix/         # nix 関連（実験用）
└── README.md
```
