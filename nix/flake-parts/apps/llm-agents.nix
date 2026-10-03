# nix/flake-parts/apps/llm-agents.nix
# apps.llm-agents-update — llm-agents.nix 由来の AI エージェントの更新
#
# 更新の主語は flake input:
#
#   llm-agents       … github:numtide/llm-agents.nix
#   llm-agents-intel … 同じリポジトリ。nixpkgs-intel を follow する x86_64-darwin 専用
#
# 実際に llm-agents から nixpkgs へ注入されるのは opencode と coderabbit-cli
# だけ (nix/overlays/ai-tools.nix)。claude-code / codex / ollama / codexbar は
# nixpkgs 由来なので、このコマンドでは更新されない (nix flake update nixpkgs の領域)。
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

      # shell の `if` へ渡すため bool を文字列へ落とす
      isIntelMacShell = if t.isIntelMac then "true" else "false";
    in
    {
      apps.llm-agents-update = {
        type = "app";
        meta.description = "llm-agents.nix 由来の AI エージェント (opencode / coderabbit-cli) を更新する";
        program = "${pkgs.writeShellScriptBin "llm-agents-update" ''
                      set -eo pipefail

                      ${c.shell.nixFeatureGuard}

                      ${c.shell.detectHelpers}

                      ${t.printInfo "llm-agents-update"}

                      # -------------------------------------------------------------------
                      # オプション
                      # -------------------------------------------------------------------
                      run_check=1
                      run_switch=1

                      for arg in "$@"; do
                        case "$arg" in
                          --no-check) run_check=0 ;;
                          --no-switch) run_switch=0 ;;
                          -h|--help)
                            cat <<'USAGE'
            nix run .#llm-agents-update [--no-check] [--no-switch]

              --no-check   `nix flake check --no-build` を走らせない
              --no-switch  最後に `nix run .#switch` を走らせない

            対象は flake.lock の llm-agents / llm-agents-intel input。
            llm-agents-intel は Intel Mac (x86_64-darwin) で実行したときだけ更新する。
          USAGE
                            exit 0
                            ;;
                          *)
                            echo "[!] 未知の引数: $arg" >&2
                            exit 1
                            ;;
                        esac
                      done

                      # -------------------------------------------------------------------
                      # 対象 input の決定
                      # -------------------------------------------------------------------
                      lock="flake.lock"

                      if [ ! -f "$lock" ]; then
                        echo "[!] $lock が見つかりません" >&2
                        echo "    この flake のディレクトリ内で実行してください" >&2
                        exit 1
                      fi

                      inputs_to_update="llm-agents"
                      if ${isIntelMacShell}; then
                        inputs_to_update="$inputs_to_update llm-agents-intel"
                        echo "  実行環境 : Intel Mac — llm-agents-intel も更新します"
                      else
                        echo "  実行環境 : Intel Mac 以外 — llm-agents-intel は対象外"
                      fi
                      echo "  対象     : $inputs_to_update"
                      echo ""

                      # -------------------------------------------------------------------
                      # 1. 更新前の rev
                      #
                      # flake.lock を直読みする。`nix flake metadata` はネットワークに
                      # 触れるので使わない。
                      # -------------------------------------------------------------------
                      read_rev() {
                        ${jq} -r --arg n "$1" '.nodes[$n].locked.rev // "unknown"' "$lock"
                      }

                      before_primary=$(read_rev llm-agents)
                      before_intel=$(read_rev llm-agents-intel)

                      echo "[1/4] 更新前"
                      echo "      llm-agents       : $before_primary"
                      if ${isIntelMacShell}; then
                        echo "      llm-agents-intel : $before_intel"
                      fi
                      echo ""

                      # -------------------------------------------------------------------
                      # 2. input bump
                      # -------------------------------------------------------------------
                      echo "[2/4] nix flake update $inputs_to_update"
                      # shellcheck disable=SC2086
                      nix flake update $inputs_to_update |& ${pkgs.nix-output-monitor}/bin/nom
                      echo ""

                      # -------------------------------------------------------------------
                      # 3. 更新後の rev と差分
                      # -------------------------------------------------------------------
                      after_primary=$(read_rev llm-agents)
                      after_intel=$(read_rev llm-agents-intel)

                      echo "[3/4] 更新後"
                      changed=0

                      if [ "$before_primary" = "$after_primary" ]; then
                        echo "      llm-agents       : $after_primary (変更なし)"
                      else
                        echo "      llm-agents       : $before_primary -> $after_primary"
                        changed=1
                      fi

                      if ${isIntelMacShell}; then
                        if [ "$before_intel" = "$after_intel" ]; then
                          echo "      llm-agents-intel : $after_intel (変更なし)"
                        else
                          echo "      llm-agents-intel : $before_intel -> $after_intel"
                          changed=1
                        fi
                      fi
                      echo ""

                      if [ "$changed" = 0 ]; then
                        echo "      差分なし"
                      else
                        echo "      flake.lock の差分は \`git diff flake.lock\` で確認してください"
                      fi
                      echo ""

                      # -------------------------------------------------------------------
                      # 4. 検証
                      # -------------------------------------------------------------------
                      if [ "$run_check" = 1 ]; then
                        echo "[4/4] nix flake check --no-build で設定の整合を検証"
                        nix flake check --no-build |& ${pkgs.nix-output-monitor}/bin/nom
                        echo "      OK"
                      else
                        echo "[4/4] 検証をスキップしました (--no-check)"
                      fi
                      echo ""

                      # -------------------------------------------------------------------
                      # 5. 反映
                      # -------------------------------------------------------------------
                      if [ "$run_switch" = 1 ]; then
                        if ! is_wsl && ! is_darwin; then
                          echo "[!] ネイティブ Linux なので OS 層 (system-manager) で sudo 認証が要ります"
                          echo ""
                        fi

                        echo "  反映します: nix run .#switch"
                        nix run .#switch |& ${pkgs.nix-output-monitor}/bin/nom
                        echo ""
                        echo "  完了"
                      else
                        echo "  反映はスキップしました (--no-switch)"
                        echo "  反映するには: nix run .#switch"
                      fi
        ''}/bin/llm-agents-update";
      };
    };
}
