# sops が展開した API キーを各 AI CLI が読む環境変数へ橋渡しする。
# Nix の pure 評価ではシークレットの値を読めないため、起動時にファイルから読む。
# 対象: opencode / Claude Code / Codex / pi (いずれも環境変数を自動で読む)。

if set -q OPENAI_API_KEY_PATH; and test -r "$OPENAI_API_KEY_PATH"
    read -l key <"$OPENAI_API_KEY_PATH"
    if test -n "$key"
        set -gx OPENAI_API_KEY (string trim -- "$key")
    end
end

if set -q ANTHROPIC_API_KEY_PATH; and test -r "$ANTHROPIC_API_KEY_PATH"
    read -l key <"$ANTHROPIC_API_KEY_PATH"
    if test -n "$key"
        set -gx ANTHROPIC_API_KEY (string trim -- "$key")
    end
end

# GitHub MCP サーバーが親プロセスの環境から読むトークン
if set -q GITHUB_TOKEN_PATH; and test -r "$GITHUB_TOKEN_PATH"
    read -l token <"$GITHUB_TOKEN_PATH"
    if test -n "$token"
        set -gx GITHUB_PERSONAL_ACCESS_TOKEN (string trim -- "$token")
    end
end
