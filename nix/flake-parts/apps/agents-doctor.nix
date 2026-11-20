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
                      echo "[1/4] 必須ファイル"
                      for f in \
                        nix/lib/ai-config.nix \
                        nix/overlays/mcp/mcp.nix \
                        nix/overlays/mcp/permissions.nix \
                        fish/conf.d/ai-secrets.fish \
                        agents/CLAUDE.md
                      do
                        if [ -f "$f" ]; then ok "$f"; else bad "$f がありません"; fi
                      done
                      echo ""

                      # -----------------------------------------------------------------
                      echo "[2/4] 単一ソースの整合"
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
                      echo "[3/4] 生成された設定 (JSON)"
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
                      if [ "$run_check" = 1 ]; then
                        echo "[4/4] nix flake check --no-build"
                        if nix flake check --no-build; then
                          ok "flake check"
                        else
                          bad "flake check が失敗しました"
                        fi
                      else
                        echo "[4/4] flake check をスキップしました (--no-check)"
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
