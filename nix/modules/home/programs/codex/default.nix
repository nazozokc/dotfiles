# nix/modules/home/programs/codex/default.nix
# OpenAI Codex CLI: グローバル指示 (AGENTS.md) をデプロイする
{
  config,
  pkgs,
  lib,
  dotfilesDir,
  ...
}:

let
  homeDir = config.home.homeDirectory;
  mcpConfig = import ../../../../overlays/mcp/mcp.nix { inherit config pkgs; };
  mcpToml = (pkgs.formats.toml { }).generate "mcp.toml" {
    mcp_servers = mcpConfig.codex;
  };
  python = pkgs.python3.withPackages (p: [ p.tomli-w ]);
in
{
  dotfiles.programs.codex = {
    icon = "🧩";
    note = "グローバル AGENTS.md + MCP";
  };

  # グローバル指示: agent-memoryの保存ルールを毎セッション読み込ませる
  home.file.".codex/AGENTS.md" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/codex/AGENTS.md";
  };

  # config.toml は Codex 自身も書き込むので、MCP セクションだけマージする。
  home.activation.codexMcp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        config="${homeDir}/.codex/config.toml"
        mkdir -p "$(dirname "$config")"
        if [ ! -f "$config" ]; then
          printf '{}\n' > "$config"
        fi
        tmp="$(mktemp "${homeDir}/.codex/config.toml.XXXXXX")"
        ${python}/bin/python3 - "$config" "${mcpToml}" "$tmp" <<'PY'
    import sys
    import tomllib
    import tomli_w

    config_path, mcp_path, out_path = sys.argv[1:4]
    with open(config_path, "rb") as f:
        config = tomllib.load(f)
    with open(mcp_path, "rb") as f:
        mcp = tomllib.load(f)
    config["mcp_servers"] = {**config.get("mcp_servers", {}), **mcp["mcp_servers"]}
    with open(out_path, "wb") as f:
        tomli_w.dump(config, f)
    PY
        mv "$tmp" "$config"
        chmod 600 "$config"
  '';
}
