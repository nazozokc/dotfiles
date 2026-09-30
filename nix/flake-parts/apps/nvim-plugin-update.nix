# nix/flake-parts/apps/nvim-plugin-update.nix
# apps.nvim-plugin-update — Neovim プラグインの更新
#
# 更新の主語は 2 つある:
#
#   1. nixpkgs 由来 (nix/plugins/nixpkgs-plugins.nix)
#      バージョンは nixpkgs が決まるので、nixpkgs input を上げるだけ。
#      Intel Mac は nixpkgs-intel を使うのでそちらも対象。
#
#   2. pin 済み (nix/plugins/pinned-plugins.json)
#      branch の最新 commit を gh api で取り、nix-prefetch-git で hash を
#      計算して JSON を書き換える。
#
# Nix 管理外の swagger-preview.nvim は lazy.nvim が持つので、ここでは触らない
# (`:Lazy update swagger-preview.nvim` で更新する)。
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
      gh = "${pkgs.gh}/bin/gh";
      nixPrefetchGit = "${pkgs.nix-prefetch-git}/bin/nix-prefetch-git";

      # shell の `if` へ渡すため bool を文字列へ落とす
      isIntelMacShell = if t.isIntelMac then "true" else "false";
    in
    {
      apps.nvim-plugin-update = {
        type = "app";
        meta.description = "Neovim プラグイン (nixpkgs 由来 + pin 済み) を更新する";
        program = "${pkgs.writeShellScriptBin "nvim-plugin-update" ''
                    set -eo pipefail

                    ${c.shell.nixFeatureGuard}

                    ${t.printInfo "nvim-plugin-update"}

                    # -------------------------------------------------------------------
                    # オプション
                    # -------------------------------------------------------------------
                    run_check=1
                    run_nixpkgs=1
                    run_pinned=1

                    for arg in "$@"; do
                      case "$arg" in
                        --no-check) run_check=0 ;;
                        --no-nixpkgs) run_nixpkgs=0 ;;
                        --no-pinned) run_pinned=0 ;;
                        -h|--help)
                          cat <<'USAGE'
          nix run .#nvim-plugin-update [--no-check] [--no-nixpkgs] [--no-pinned]

            --no-check     最後に `nix flake check --no-build` を走らせない
            --no-nixpkgs   nixpkgs input を更新しない
            --no-pinned    nix/plugins/pinned-plugins.json を更新しない

          対象ファイルを相対パスで解決するため、この flake のディレクトリ内で実行すること。
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
                    lock="nix/plugins/pinned-plugins.json"
                    map="nix/plugins/nixpkgs-plugins.nix"

                    if [ ! -f "$lock" ] || [ ! -f "$map" ]; then
                      echo "[!] $lock / $map が見つかりません" >&2
                      echo "    この flake のディレクトリ内で実行してください" >&2
                      exit 1
                    fi

          # nixpkgs-plugins.nix は Nix の attrset なので jq ではなく行数で数える
          nixpkgs_managed=$(grep -c '^\s*"[^"]*" = ' "$map" || true)
          pinned_managed=$(${jq} -r 'length' "$lock")
                    echo "  対象      : nixpkgs 由来 $nixpkgs_managed / pin 済み $pinned_managed"
                    echo "  lockfile  : $lock"
                    echo ""

                    if ! ${gh} auth status >/dev/null 2>&1; then
                      echo "[!] gh が認証されていません (\`gh auth login\` を実行してください)" >&2
                      exit 1
                    fi

                    # -------------------------------------------------------------------
                    # 1. nixpkgs input
                    # -------------------------------------------------------------------
                    if [ "$run_nixpkgs" = 1 ]; then
                      echo "[1/2] nixpkgs input を更新"
                      nix flake update nixpkgs |& ${pkgs.nix-output-monitor}/bin/nom
                      if ${isIntelMacShell}; then
                        nix flake update nixpkgs-intel |& ${pkgs.nix-output-monitor}/bin/nom
                      fi
                      echo "      nixpkgs 由来 $nixpkgs_managed 件はこれで追従完了"
                      echo ""
                    fi

                    # -------------------------------------------------------------------
                    # 2. pin 済みプラグイン
                    # -------------------------------------------------------------------
                    changed=0
                    skipped=0

                    if [ "$run_pinned" = 1 ]; then
                      echo "[2/2] pin 済みプラグインを更新"
                      tmp="$lock.tmp"
                      ${jq} '.' "$lock" >"$tmp"

                      while IFS=$'\t' read -r name url branch rev; do
                        [ -n "$name" ] || continue

                        # GitHub 以外は branch 追跡の対象外 (SourceHut など)
                        case "$url" in
                          https://github.com/*)
                            slug="$(printf '%s' "$url" | sed -e 's#^https://github.com/##' -e 's#\.git$##')"
                            ;;
                          *)
                            echo "      [skip] $name: GitHub 以外のホスト ($url)"
                            skipped=$((skipped + 1))
                            continue
                            ;;
                        esac

                        if ! latest=$(${gh} api "repos/$slug/commits/$branch" --jq .sha 2>/dev/null); then
                          echo "      [warn] $name: $slug@$branch を取得できませんでした (スキップ)"
                          skipped=$((skipped + 1))
                          continue
                        fi

                        if [ "$latest" = "$rev" ]; then
                          echo "      [ok]   $name: $rev (最新)"
                          continue
                        fi

                        if ! hash=$(${nixPrefetchGit} --quiet "$url" "$latest" 2>/dev/null | ${jq} -r .hash); then
                          echo "      [warn] $name: $latest の hash を計算できませんでした (スキップ)"
                          skipped=$((skipped + 1))
                          continue
                        fi

                        echo "      [upd]  $name: $rev -> $latest"
                        ${jq} --arg n "$name" --arg r "$latest" --arg h "$hash" \
                          '.[$n].rev = $r | .[$n].hash = $h' "$tmp" >"$tmp.next"
                        mv "$tmp.next" "$tmp"
                        changed=$((changed + 1))
                      done < <(${jq} -r 'to_entries[] | [.key, .value.url, .value.branch, .value.rev] | @tsv' "$lock")

                      if [ "$changed" -gt 0 ]; then
                        ${jq} --indent 2 '.' "$tmp" >"$tmp.pretty"
                        mv "$tmp.pretty" "$lock"
                        rm -f "$tmp"
                        echo "      $lock を更新しました ($changed 件)"
                      else
                        rm -f "$tmp"
                        echo "      更新なし"
                      fi
                      echo ""

                      if [ "$skipped" -gt 0 ]; then
                        echo "      注意: $skipped 件は自動更新できませんでした (上の [skip]/[warn] を参照)"
                        echo ""
                      fi
                    fi

                    # -------------------------------------------------------------------
                    # 3. 検証
                    # -------------------------------------------------------------------
                    # nix/plugins/nixpkgs-plugins.nix の attr が消えていたら
                    # ここで「どのプラグインの attr が無い」かが評価エラーとして出る。
                    if [ "$run_check" = 1 ]; then
                      echo "[3/3] nix flake check --no-build で設定の整合を検証"
                      nix flake check --no-build |& ${pkgs.nix-output-monitor}/bin/nom
                      echo "      OK"
                    else
                      echo "[3/3] 検証をスキップしました (--no-check)"
                    fi

                    echo ""
                    echo "  反映するには: nix run .#switch"
        ''}/bin/nvim-plugin-update";
      };
    };
}
