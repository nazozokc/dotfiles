{ ... }:

{
  imports = [
    # 適用メッセージの集約先。各プログラムモジュールは
    # `dotfiles.programs.<name>` を書くだけ (applied.nix 参照)
    ./programs/applied.nix
    ./programs/gh
    ./programs/pnpm
    ./programs/bun
    ./programs/git
    ./programs/lazygit
    ./programs/cmux
    ./programs/starship
    ./programs/direnv.nix
    ./programs/fzf
    ./programs/bat
    ./programs/tmux
    ./programs/yazi
    ./programs/jujutsu
    ./programs/sops
    ./programs/opencode
    ./programs/claude-code
    ./programs/codex
    ./programs/ghostty.nix
    ./programs/ollama
    ./programs/docker
    ./programs/gh-dash
    ./programs/fish
  ];
}
