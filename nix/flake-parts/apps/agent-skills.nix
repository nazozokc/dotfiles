# nix/flake-parts/apps/agent-skills.nix
# apps.agents-skills-update — Agent Skills の更新と自己検証
#
# 更新の主語は 2 つある:
#
#   1. agent-skills-nix input (github:Kyure-A/agent-skills-nix)
#      フレームワーク自体なので、input を上げるだけ。
#
#   2. agents/skills/ (nix/modules/home/agent-skills.nix の sources.local)
#      agents/skills/* はすべて自前の手書きで upstream origin がない。
#      したがって「更新」=</ 自己検証。eval 期に落ちないものだけを見る:
#        - SKILL.md の欠落 / frontmatter の欠落
#        - frontmatter の name とディレクトリ名が不一致
#        - name の重複
#        - agents/CLAUDE.md のインデックスと実体の drift
#
#      discoverCatalog は source 設定の不備を評価時に落とすため、構造的な誤りは
#      末尾の `nix flake check --no-build` が既にカバーする。ここで見るのは
#      「評価は通るが意図とずれている」ものだけ。
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
      apps.agents-skills-update = {
        type = "app";
        meta.description = "agent-skills-nix input を更新し、agents/skills/ を自己検証する";
        program = "${pkgs.writeShellScriptBin "agents-skills-update" ''
                      set -eo pipefail

                      ${c.shell.nixFeatureGuard}

                      ${c.shell.detectHelpers}

                      ${t.printInfo "agents-skills-update"}

                      # -------------------------------------------------------------------
                      # オプション
                      # -------------------------------------------------------------------
                      run_check=1
                      run_switch=1
                      run_validate=1

                      for arg in "$@"; do
                        case "$arg" in
                          --no-check) run_check=0 ;;
                          --no-switch) run_switch=0 ;;
                          --no-validate) run_validate=0 ;;
                          -h|--help)
                            cat <<'USAGE'
            nix run .#agents-skills-update [--no-check] [--no-switch] [--no-validate]

              --no-check     `nix flake check --no-build` を走らせない
              --no-switch    最後に `nix run .#switch` を走らせない
              --no-validate  agents/skills/ の自己検証を走らせない

            agents/skills/* は自前の手書きで upstream がないので、ここでは
            「更新」ではなく整合性の検証だけを行う。agents/CLAUDE.md の
            インデックスに漏れがあっても自動修正はしない (報告のみ)。
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
                      # 対象ファイルの所在確認
                      # -------------------------------------------------------------------
                      lock="flake.lock"
                      skills_dir="agents/skills"
                      index="agents/CLAUDE.md"
                      module="nix/modules/home/agent-skills.nix"

                      for f in "$lock" "$index" "$module"; do
                        if [ ! -f "$f" ]; then
                          echo "[!] $f が見つかりません" >&2
                          echo "    この flake のディレクトリ内で実行してください" >&2
                          exit 1
                        fi
                      done

                      if [ ! -d "$skills_dir" ]; then
                        echo "[!] $skills_dir/ が見つかりません" >&2
                        exit 1
                      fi

                      # -------------------------------------------------------------------
                      # 1. agent-skills-nix input の更新
                      # -------------------------------------------------------------------
                      echo "[1/4] agent-skills-nix input"
                      before=$(${jq} -r '.nodes["agent-skills-nix"].locked.rev // "unknown"' "$lock")
                      echo "      更新前 : $before"
                      nix flake update agent-skills-nix |& ${pkgs.nix-output-monitor}/bin/nom
                      after=$(${jq} -r '.nodes["agent-skills-nix"].locked.rev // "unknown"' "$lock")
                      echo "      更新後 : $after"
                      if [ "$before" = "$after" ]; then
                        echo "      変更なし"
                      else
                        echo "      差分は \`git diff flake.lock\` で確認してください"
                      fi
                      echo ""

                      # -------------------------------------------------------------------
                      # 2. agents/skills/ の自己検証
                      # -------------------------------------------------------------------
                      if [ "$run_validate" = 1 ]; then
                        echo "[2/4] $skills_dir/ を検証"

                        names=$(mktemp)
                        trap 'rm -f "$names"' EXIT

                        total=0
                        failed=0
                        warned=0

                        for d in $(ls -1 "$skills_dir" | sort); do
                          [ -d "$skills_dir/$d" ] || continue
                          total=$((total + 1))
                          f="$skills_dir/$d/SKILL.md"

                          if [ ! -f "$f" ]; then
                            echo "      [fail] $d: SKILL.md がありません"
                            failed=$((failed + 1))
                            continue
                          fi

                          # frontmatter は 1 行目から最初に出るので、最初の
                          # 一致行で確定する (本文中の `name:` は拾わない)
                          name=$(grep -m1 '^name:' "$f" 2>/dev/null | sed 's/^name:[[:space:]]*//' || true)
                          desc=$(grep -m1 '^description:' "$f" 2>/dev/null | sed 's/^description:[[:space:]]*//' || true)

                          if [ -z "$name" ]; then
                            echo "      [fail] $d: frontmatter に name がありません"
                            failed=$((failed + 1))
                            continue
                          fi

                          if [ -z "$desc" ]; then
                            echo "      [fail] $d: frontmatter に description がありません"
                            failed=$((failed + 1))
                            continue
                          fi

                          if [ "$name" != "$d" ]; then
                            echo "      [warn] $d: frontmatter の name は '$name'"
                            warned=$((warned + 1))
                          fi

                          case "$name" in
                            [a-z0-9]*) ;;
                            *)
                              echo "      [warn] $d: name '$name' は小文字の slug ではありません"
                              warned=$((warned + 1))
                              ;;
                          esac

                          printf '%s\n' "$name" >>"$names"
                        done

                        # name の重複
                        dup=$(sort "$names" | uniq -d)
                        if [ -n "$dup" ]; then
                          for n in $dup; do
                            echo "      [fail] name '$n' が複数ディレクトリで使われています"
                            failed=$((failed + 1))
                          done
                        fi

                        # agents/CLAUDE.md のインデックスとの drift
                        indexed=$(grep -o 'skills/[a-z0-9-]*/SKILL\.md' "$index" \
                          | sed -e 's|^skills/||' -e 's|/SKILL\.md$||' | sort -u || true)
                        present=$(ls -1 "$skills_dir" | sort)

                        not_indexed=$(comm -23 <(printf '%s\n' "$present") <(printf '%s\n' "$indexed"))
                        no_dir=$(comm -13 <(printf '%s\n' "$present") <(printf '%s\n' "$indexed"))

                        if [ -n "$not_indexed" ]; then
                          for n in $not_indexed; do
                            echo "      [warn] $n: $index のインデックスに載っていません"
                            warned=$((warned + 1))
                          done
                        fi

                        if [ -n "$no_dir" ]; then
                          for n in $no_dir; do
                            echo "      [fail] $n: $index に載っているが $skills_dir/$n がありません"
                            failed=$((failed + 1))
                          done
                        fi

                        echo ""
                        echo "      スキル数 : $total"
                        echo "      索引数   : $(printf '%s\n' "$indexed" | grep -c . || true)"
                        echo "      ターゲット: $(grep -c 'dest = "' "$module" || true) 件"
                        grep -o 'dest = "[^"]*"' "$module" | sed 's/^/        /' || true
                        echo "      警告 $warned 件 / 失敗 $failed 件"
                        echo ""

                        if [ "$failed" -gt 0 ]; then
                          echo "[!] $failed 件が不正です。上の [fail] を参照してください" >&2
                          echo "    $index のインデックスは自動修正しません" >&2
                          exit 1
                        fi
                      else
                        echo "[2/4] 自己検証をスキップしました (--no-validate)"
                        echo ""
                      fi

                      # -------------------------------------------------------------------
                      # 3. 検証
                      # -------------------------------------------------------------------
                      if [ "$run_check" = 1 ]; then
                        echo "[3/4] nix flake check --no-build で設定の整合を検証"
                        nix flake check --no-build |& ${pkgs.nix-output-monitor}/bin/nom
                        echo "      OK"
                      else
                        echo "[3/4] 検証をスキップしました (--no-check)"
                      fi
                      echo ""

                      # -------------------------------------------------------------------
                      # 4. 反映
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
        ''}/bin/agents-skills-update";
      };
    };
}
