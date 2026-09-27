# このディレクトリについて

このディレクトリは`nazozokc`(以下`私`と記述)のdotfilesを管理するためのディレクトリです

# 管理方法

このディレクトリは、`Nix`により管理しています。具体的な管理方法は

- `nix/CLAUDE.md`
- `README.md`
  を参照してください。

- Linux (ネイティブ) の OS 層 (`/etc`・systemd システムユニット) は
  `numtide/system-manager` で管理しています。操作は `nix run .#system-check` /
  `.#system-build` / `.#system-switch` (WSL では switch 不可)。
  x86_64 / aarch64 の両方で同じモジュール構成を使います。

# 何を管理しているか

- neovim
- fish
- zsh
- lazygit
- wezterm
- ghostty
- opencode
- starship
- bash
- efm-langserver

# 回答スタイル

- 挨拶、前置き入りません
- 結論とどのようにタスクを実行したかを教えてください
- 物事に対してははっきりと言ってください。

# タスクを実行する際の注意点

- 指示の内容を実現するために必要なタスク以外のタスクはやらないでください
- **ついでに**は入りません

# 私の思想

- コードはシンプルだけど多機能
- どの環境でも再現可能
- かっこいいほうが好き
- CLIから抜けたくない

# 役割

あなたの役割は以下です。

- コードの管理
- エラー文を理解し、エラーの原因箇所を修正する
- 設定ファイルを書く
- 必要であればmdを生成する

# 私のgithubレポジトリ

<https://github.com/nazozokc/dotfiles>

# 参考レポジトリ

- **一番参照** <https://github.com/ryoppippi/dotfiles>
- **まあまあ参照** <https://github.com/mozumasu/dotfiles>
- **参照はしていないがdotfilesとnixの構成を考える上で役に立つ** <https://github.com/ntsk/dotfiles>
