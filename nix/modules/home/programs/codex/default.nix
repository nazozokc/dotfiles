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
  permConfig = import ../../../../overlays/mcp/permissions.nix { };
  roles = import ../../../../lib/agent-roles.nix;
  tomlFormat = pkgs.formats.toml { };
  mcpToml = tomlFormat.generate "mcp.toml" {
    mcp_servers = mcpConfig.codex;
  };

  # Codex は ~/.codex/agents/<role>.toml をスキャンして role を登録する。
  # ファイル側に developer_instructions が必要 (detected file は role_name_hint が無い)。
  codexAgents = lib.listToAttrs (
    map (
      name:
      let
        role = builtins.getAttr name roles;
        promptText = role.prompt;
      in
      {
        name = ".codex/agents/${name}.toml";
        value.source = tomlFormat.generate "${name}.toml" {
          inherit name;
          inherit (role) description;
          developer_instructions = promptText;
        };
      }
    ) roles.roles
  );

  python = pkgs.python3.withPackages (p: [ p.tomli-w ]);
in
{
  dotfiles.programs.codex = {
    icon = "🧩";
    note = "グローバル AGENTS.md + MCP + 6 agents";
  };

  # グローバル指示: agent-memoryの保存ルールを毎セッション読み込ませる
  home.file = codexAgents // {
    ".codex/AGENTS.md" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/codex/AGENTS.md";
    };
  };

  # config.toml は Codex 自身も書き込むので、MCP セクションだけマージする。
  home.activation.codexMcp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        config="${homeDir}/.codex/config.toml"
        mkdir -p "$(dirname "$config")"
        if [ ! -f "$config" ]; then
          printf '{}\n' > "$config"
        fi
        tmp="$(mktemp "${homeDir}/.codex/config.toml.XXXXXX")"
        ${python}/bin/python3 - "$config" "${mcpToml}" "$tmp" '${builtins.toJSON permConfig.codex}' <<'PY'
    import json
    import sys
    import tomllib
    import tomli_w

    config_path, mcp_path, out_path, perms_json = sys.argv[1:5]
    with open(config_path, "rb") as f:
        config = tomllib.load(f)
    with open(mcp_path, "rb") as f:
        mcp = tomllib.load(f)
    # 権限は共通定義 (overlays/mcp/permissions.nix) を正本として上書きする
    config.update(json.loads(perms_json))
    config["mcp_servers"] = {**config.get("mcp_servers", {}), **mcp["mcp_servers"]}
    # subagent は 1 段だけ。max_threads は max_concurrent_threads_per_session の alias。
    config["agents"] = {**config.get("agents", {}), "max_threads": 6, "max_depth": 1}
    with open(out_path, "wb") as f:
        tomli_w.dump(config, f)
    PY
        mv "$tmp" "$config"
        chmod 600 "$config"
  '';
}
