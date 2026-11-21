# nix/flake-parts/apps/agents-doctor.nix
# apps.agents-doctor — AI エージェント設定の自己診断 (read-only・反映しない)
{ inputs, ... }:
let
  c = import ./common.nix { inherit inputs; };
in
{
  perSystem =
    { pkgs, system, ... }:
    let
      t = c.targetsFor system;
      jq = "${pkgs.jq}/bin/jq";
    in
    {
      apps.agents-doctor = {
        type = "app";
        meta.description = "MCP / 権限 / シークレット / エージェント設定を診断する";
        program = "${pkgs.writeShellScriptBin "agents-doctor" ''
                      set -eo pipefail

                      ${c.shell.nixFeatureGuard}

                      ${t.printInfo "agents-doctor"}

                      run_check=1
                      for arg in "$@"; do
                        case "$arg" in
                          --no-check) run_check=0 ;;
                          -h|--help)
                            cat <<'USAGE'
            nix run .#agents-doctor [--no-check]

              --no-check  最後の `nix flake check --no-build` を走らせない

            設定を書き換えず、AI エージェント関連の定義と生成物だけを診断する。
          USAGE
                            exit 0
                            ;;
                          *)
                            echo "[!] 未知の引数: $arg" >&2
                            exit 1
                            ;;
                        esac
                      done

                       hc=".#homeConfigurations.${c.identity.username}"

                       fail=0
                       ok() { printf '      [ok] %s\n' "$1"; }

                      bad() { printf '      [fail] %s\n' "$1"; fail=$((fail + 1)); }

                      # -----------------------------------------------------------------
                      echo "[1/5] 必須ファイル"
                      for f in \
                        nix/lib/ai-config.nix \
                        nix/lib/agent-roles.nix \
                        nix/overlays/mcp/mcp.nix \
                        nix/overlays/mcp/permissions.nix \
                        fish/conf.d/ai-secrets.fish \
                        agents/CLAUDE.md \
                        nix/modules/home/programs/pi/extensions/parallel-agents/agents.ts
                      do
                        if [ -f "$f" ]; then ok "$f"; else bad "$f がありません"; fi
                      done
                      echo ""

                      # -----------------------------------------------------------------
                      echo "[2/5] 単一ソースの整合"
                      mcp="nix/overlays/mcp/mcp.nix"
                      perm="nix/overlays/mcp/permissions.nix"
                      ai="nix/lib/ai-config.nix"
                      secrets="fish/conf.d/ai-secrets.fish"

                      for name in context7 TypescriptDocs github git nixos; do
                        if grep -q "^    $name = {" "$mcp"; then
                          ok "MCP server: $name"
                        else
                          bad "MCP server: $name がありません"
                        fi
                      done

                      if grep -q '/bin/bunx' "$mcp"; then
                        bad "MCP に bunx -y 依存が残っています"
                      else
                        ok "MCP は Nix store の実体のみ"
                      fi

                      for f in \
                        nix/modules/home/programs/opencode/default.nix \
                        nix/modules/home/programs/claude-code/default.nix \
                        nix/modules/home/programs/codex/default.nix
                      do
                        if grep -q 'overlays/mcp/permissions.nix' "$f"; then
                          ok "$(basename "$(dirname "$f")") が権限の共通定義を参照"
                        else
                          bad "$f が権限の共通定義を参照していません"
                        fi
                      done

                      for key in opencode claudeCode codex; do
                        if grep -q "^  $key =" "$perm"; then
                          ok "共通権限: $key"
                        else
                          bad "共通権限: $key がありません"
                        fi
                      done

                      for f in \
                        nix/modules/home/programs/opencode/default.nix \
                        nix/modules/home/programs/claude-code/default.nix \
                        nix/modules/home/programs/codex/default.nix
                      do
                        if grep -q 'lib/agent-roles.nix' "$f"; then
                          ok "$(basename "$(dirname "$f")") が共通ロール定義を参照"
                        else
                          bad "$f が共通ロール定義を参照していません"
                        fi
                      done

                      for var in OPENAI_API_KEY ANTHROPIC_API_KEY GITHUB_PERSONAL_ACCESS_TOKEN; do
                        if grep -q "set -gx $var" "$secrets"; then
                          ok "secret bridge: $var"
                        else
                          bad "secret bridge: $var がありません"
                        fi
                      done

                      for key in t3codeProvider t3codeModels ollamaModels; do
                        if grep -q "^  $key =" "$ai"; then
                          ok "ai-config: $key"
                        else
                          bad "ai-config: $key がありません"
                        fi
                      done
                      echo ""

                      # -----------------------------------------------------------------
                      echo "[3/5] 生成された設定 (JSON)"
                      check_json() {
                        label=$1
                        apply=$2
                        if raw=$(nix eval --raw --apply "$apply" "$hc.config.xdg.configFile") \
                          && printf '%s\n' "$raw" | ${jq} -e . >/dev/null 2>&1
                        then
                          ok "$label"
                        else
                          bad "$label が不正です"
                        fi
                      }
                      check_json "opencode/opencode.json" 'f: f."opencode/opencode.json".text'
                      check_json "opencode/tui.json" 'f: f."opencode/tui.json".text'
                      check_json "pi/agent/settings.json" 'f: f."pi/agent/settings.json".text'
                       check_json "pi/agent/mcp.json" 'f: f."pi/agent/mcp.json".text'
                       echo ""

                       # -----------------------------------------------------------------
                       echo "[4/5] subagent 定義"
                       roles_json=$(nix eval --file ./nix/lib/agent-roles.nix --raw --apply 'r: builtins.toJSON (builtins.listToAttrs (map (n: { name = n; value = { description = (builtins.getAttr n r).description; prompt = (builtins.getAttr n r).prompt; }; }) r.roles))' 2>/dev/null)

                       # opencode: mode / permission.task / 共通 prompt の一致
                       oc=$(nix eval --raw --apply 'f: f."opencode/opencode.json".text' "$hc.config.xdg.configFile" 2>/dev/null)
                       if printf '%s\n' "$oc" | ${jq} -e --argjson roles "$roles_json" '
                         . as $c
                         | ($c.agent | to_entries) as $entries
                         | (($entries | map(select(.value.mode == "subagent") | .key) | sort) == ["explore","review","scout","test"])
                         and ($entries | map(select(.value.mode == "subagent") | .value.permission.task["*"]) | all(. == "deny"))
                         and ($c.agent[$c.default_agent].mode == "primary")
                         and (($c.permission.task | to_entries | map(select(.value == "allow") | .key) | sort) == ["explore","review","scout","test"])
                         and (["build","plan","explore","scout","review","test"] | all(.[]; . as $k | $c.agent[$k].prompt == $roles[$k].prompt))
                       ' >/dev/null 2>&1
                       then
                         ok "opencode: 4 subagent + 親の task glob + prompt"
                       else
                         bad "opencode: subagent 定義が共通ロールと一致しません"
                       fi

                       # claude-code: 6 ロールの frontmatter と prompt
                       claude_agents=$(nix eval --raw --apply 'f: builtins.toJSON (builtins.listToAttrs (map (n: { name = n; value = ((builtins.getAttr (".claude/agents/" + n + ".md") f).text or ""); }) [ "build" "plan" "explore" "scout" "review" "test" ]))' "$hc.config.home.file" 2>/dev/null)
                       if printf '%s\n' "$claude_agents" | ${jq} -e --argjson roles "$roles_json" '
                         keys == ($roles | keys)
                         and (to_entries | all(.[]; . as $e | $e.value | contains("name: " + $e.key) and contains("description: " + $roles[$e.key].description) and contains($roles[$e.key].prompt)))
                       ' >/dev/null 2>&1
                       then
                         ok "claude-code: 6 agent の frontmatter + prompt"
                       else
                         bad "claude-code: agent 定義が共通ロールと一致しません"
                       fi

                       # codex: role TOML 6 個 + ネスト制限
                       codex_agents=$(nix eval --raw --apply 'f: builtins.toJSON (map (n: builtins.hasAttr (".codex/agents/" + n + ".toml") f) [ "build" "plan" "explore" "scout" "review" "test" ])' "$hc.config.home.file" 2>/dev/null)
                       if printf '%s\n' "$codex_agents" | ${jq} -e 'all(.[]; . == true)' >/dev/null 2>&1; then
                         ok "codex: 6 agent role TOML"
                       else
                         bad "codex: agent role TOML が不足しています"
                       fi
                       if grep -Eq 'max_depth[^0-9]*1' nix/modules/home/programs/codex/default.nix \
                         && grep -Eq 'max_threads[^0-9]*6' nix/modules/home/programs/codex/default.nix
                       then
                         ok "codex: subagent は 1 段 (max_depth=1 / max_threads=6)"
                       else
                         bad "codex: [agents] のネスト制限がありません"
                       fi

                       # pi: parallel-agents と agent-modes の prompt drift
                       pi_agents=nix/modules/home/programs/pi/extensions/parallel-agents/agents.ts
                       for role in build plan explore scout review test; do
                         prompt=$(nix eval --file ./nix/lib/agent-roles.nix --raw --apply "r: r.$role.prompt" 2>/dev/null)
                         desc=$(nix eval --file ./nix/lib/agent-roles.nix --raw --apply "r: r.$role.description" 2>/dev/null)
                         if grep -Fq "$prompt" "$pi_agents" && grep -Fq "$desc" "$pi_agents"; then
                           ok "pi parallel-agents: $role"
                         else
                           bad "pi parallel-agents: $role の prompt/description が drift"
                         fi
                       done
                       if grep -Eq '(researcher|reviewer|tester|implementer)' "$pi_agents"; then
                         bad "pi parallel-agents: 旧ロール名が残っています"
                       else
                         ok "pi parallel-agents: ロール名は共通定義に統一"
                       fi
                       for role in build plan explore scout; do
                         prompt=$(nix eval --file ./nix/lib/agent-roles.nix --raw --apply "r: r.$role.prompt" 2>/dev/null)
                         if grep -Fq "$prompt" "nix/modules/home/programs/pi/extensions/agent-modes/$role.ts"; then
                           ok "pi agent-modes: $role"
                         else
                           bad "pi agent-modes: $role の prompt が drift"
                         fi
                       done
                       echo ""

                       # -----------------------------------------------------------------
                       if [ "$run_check" = 1 ]; then
                         echo "[5/5] nix flake check --no-build"
                        if nix flake check --no-build; then
                          ok "flake check"
                        else
                          bad "flake check が失敗しました"
                        fi
                      else
                         echo "[5/5] flake check をスキップしました (--no-check)"
                      fi

                      if [ "$fail" -gt 0 ]; then
                        echo ""
                        echo "[!] $fail 件の問題があります" >&2
                        exit 1
                      fi
                      echo ""
                      echo "  問題なし"
        ''}/bin/agents-doctor";
      };
    };
}
