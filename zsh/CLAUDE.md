# 最初にやること
/home/nazozokc/agents/CLAUDE.mdを読み込んでください

# Zsh Configuration

このディレクトリは nazozokc の Zsh 設定です。

## 構成

- **zshrc**: Oh My Zsh 読み込み後、ユーザー設定を記述
- **zshrc.pre-oh-my-zsh**: Oh My Zsh インストール前用の簡易設定

## 主要機能

### テーマ & プラグイン
- テーマ: Powerlevel10k
- Oh My Zsh 経由で以下のプラグインをロード:
  - git, zsh-autosuggestions, zsh-syntax-highlighting
  - fzf-tab, fzf, git-open
  - zsh-you-should-use, zsh-interactive-cd, zsh-vi-mode
  - zsh-autocomplete, zsh-history-enquirer, fast-syntax-highlighting

### カスタム関数
- `chpwd()`: ディレクトリ移動時に `eza -lah --icons --git` を実行
- `list()`: eza でファイル一覧表示
- `cdf()`: fzf でディレクトリ選択して移動

### アリASES
| alias | コマンド |
|-------|----------|
| vim | nvim |
| clr | clear |
| q | exit |
| typescript-enviroment | sudo npm i -D typescript ts-node-dev @types/node @types/express |

## ディレクトリ構成

```
zsh/
├── CLAUDE.md
├── zshrc              # main zshrc (Oh My Zsh 後の設定)
└── zshrc.pre-oh-my-zsh # Oh My Zsh 前用の簡易設定
```

## Home Manager 連携

`nix/modules/home-manager/symlinks.nix` で `~/.zshrc` にシンボリックリンクを作成。
