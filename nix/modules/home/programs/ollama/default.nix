{
  pkgs,
  ...
}:
{
  dotfiles.programs.ollama = {
    icon = "🦙";
    note = "127.0.0.1:11434";
  };

  services.ollama = {
    enable = true;
    # acceleration = null;  # null: デフォルト, "cuda": NVIDIA, "rocm": AMD
    host = "127.0.0.1";
    port = 11434;
  };

  # oterm は無効化中: nixpkgs の mcp 2.x が McpError -> MCPError にリネームした影響で
  # fastmcp 3.x が import 時に落ちる (oterm -> fastmcp -> mcp)。全プラットフォーム対象。
  # 復活条件: fastmcp 4.x 化 PR https://github.com/NixOS/nixpkgs/pull/563493 か
  #   oterm 0.26.0 化 PR https://github.com/NixOS/nixpkgs/pull/567684 のマージ後に戻す。
  # なお x86_64-darwin (Intel Mac) は従来通り除外:
  # - oterm: fastmcp -> duckdb -> pyarrow -> arrow-cpp (x86_64-darwin で broken)
  # - aider-chat-full: grep-ast -> tree-sitter-language-pack (x86_64-darwin のバンドルなし)
  home.packages =
    with pkgs;
    lib.optionals (pkgs.stdenv.hostPlatform.system != "x86_64-darwin") [
      aider-chat-full
    ];
}
