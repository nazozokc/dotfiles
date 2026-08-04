{
  pkgs,
  ...
}:
{
  services.ollama = {
    enable = true;
    # acceleration = null;  # null: デフォルト, "cuda": NVIDIA, "rocm": AMD
    host = "127.0.0.1";
    port = 11434;
  };

  # oterm / aider-chat-full は x86_64-darwin (Intel Mac) でビルド不能のため除外
  # - oterm: fastmcp -> duckdb -> pyarrow -> arrow-cpp (x86_64-darwin で broken)
  # - aider-chat-full: grep-ast -> tree-sitter-language-pack (x86_64-darwin のバンドルなし)
  home.packages =
    with pkgs;
    lib.optionals (pkgs.stdenv.hostPlatform.system != "x86_64-darwin") [
      oterm
      aider-chat-full
    ];
}
