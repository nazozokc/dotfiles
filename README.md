# nazozo dotfiles

Arch Linux + Nix + Home Manager による
ユーザー空間完全再現型 dotfiles 構成。

---

## 🧠 設計思想

- OS レイヤーは Arch (pacman) が管理
- アプリケーション層は Nix が管理
- 設定ファイルは Home Manager が symlink 管理
- dotfiles は生ファイルのまま管理（Lua / fish 等を書き直さない）
- リポジトリが唯一の正

---

## 🧱 レイヤー構成

```

Arch Linux (pacman)
├─ Kernel / KDE / systemd / Driver
└─ ベースシステム

Nix (home-manager)
├─ CLIツール
├─ LSPバイナリ
├─ GUIアプリ
└─ Neovim本体

Home Manager
└─ dotfiles シンボリックリンク生成

```

---

## 📦 管理対象

### CLI

- git
- curl / wget
- ripgrep
- fd
- bat
- eza
- fzf
- jq
- tree
- zip / unzip

### LSP

- lua-language-server
- nil
- pyright
- typescript-language-server
- bash-language-server
- clangd
- marksman

### GUI

- zen-browser
- spotify
- discord
- vscode
- wezterm

### Fonts

- Nerd Fonts（Hack / JetBrainsMono など）

---

## 🔗 dotfiles 管理

管理対象:

- ~/.config/fish
- ~/.config/nvim
- ~/.config/wezterm
- ~/.zshrc

すべて:

```

recursive = true;
force = true;

````

ローカル変更は上書きされる。

---

## 🚀 初回セットアップ

```bash
git clone <repo>
cd dotfiles
exec bash
nix run github:nix-community/home-manager -- switch --flake .
````

---

## 🔄 アップデート方法

```bash
nix flake update
exec bash
home-manager switch --flake .
```

---

## ⚠ 注意

* fish 起動中に home-manager を実行しない
* unfree パッケージ（discord / spotify）は allowUnfree 必須
* pacman と nix の役割を混ぜない

# LICENSE
MIT
