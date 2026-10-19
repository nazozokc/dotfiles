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
- **NixOS** の場合は `nixosConfigurations` (`nix/modules/nixos/` + `nix/hosts/`) を使い、
  `nixos-rebuild switch --flake .#nazozokc` で適用します。
  `nix run .#switch` は `/etc/NIXOS` を検出して自動で nixos-rebuild に委譲します。
  ホストの disk layout は `nix/hosts/<name>/hardware-configuration.nix` にコミットします。

# 何を管理しているか

設定モジュール (`nix/modules/home/programs/`) で管理:

- シェル / ターミナル: fish, zsh, bash, starship, tmux, ghostty, wezterm
- エディタ: neovim, vscode (Linux/macOS), efm-langserver
- AI エージェント: opencode, pi, claude-code, codex, ollama
- Git / GitHub: git, lazygit, gh, gh-dash, jujutsu
- ターミナルツール: bat, fzf, yazi, direnv, pnpm, bun, docker, sops, cmux
- デスクトップ: hypr (Hyprland), herdr, aerospace (macOS)
- その他: mise, my_scripts, agents/skills

OS 層 (`/etc`・systemd) は system-manager で管理 (上記「管理方法」参照)。
プラットフォーム別の適用範囲は `nix/README.md` を参照。

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
