# nix/flake-parts/apps/system.nix
# OS 層 (numtide/system-manager) の 3 コマンド
#
#   system-build   … toplevel (linkFarm) のビルド。評価のみ・副作用なし
#   system-check   … switch 前の dry-run 相当。sudo 不要。評価エラーと差分を確認
#   system-switch  … 実際の適用。/etc と systemd システムユニットを書き換える (sudo 必要)
#
# いずれもネイティブ Linux (systemd) 専用。WSL は .wslconfig の管轄、
# macOS は nix-darwin の管轄なので実行を拒否する。
{ inputs, ... }:
let
  c = import ./common.nix { inherit inputs; };
in
{
  perSystem =
    { pkgs, system, ... }:
    let
      t = c.targetsFor system;

      # 3 コマンド共通の前提チェック (systemConfigName の案内まで出す)
      # 末尾の改行を落として、埋め込み後に空行が増えないようにする
      # NixOS では systemConfigs ではなく nixosConfigurations を使うため
      # is_nixos 分岐でターゲット表示を切り替える
      linuxOnlyGuard = pkgs.lib.removeSuffix "\n" ''
        if is_darwin; then
          echo "[!] system-manager は Linux 専用です"
          exit 1
        fi

        if is_wsl; then
          echo "[!] WSL は対象外です"
          echo "    WSL の OS 設定は wsl/.wslconfig (Windows 側) を参照"
          exit 1
        fi

        if is_nixos; then
          echo "  system : ${t.sysLabel} (NixOS)"
          echo "  target : .#${t.nixosConfigName} (nixosConfigurations)"
        else
          echo "  system : ${t.sysLabel}"
          echo "  target : .#systemConfigs.${t.systemConfigName}"
        fi
      '';

      # system-manager 呼び出しの共通前置き。
      #
      # 属性は flake URI の '#' 以降で渡す (--attr フラグは無い)。
      # 素の '.#' では hostname → default の順で解決され、
      # systemConfigs.${t.systemConfigName} に到達しない
      #
      # system-manager の input は store path に展開されるため、
      # 属性なしの installable は Nix 式として解釈されて失敗する。
      # '#default' を付けて flake として解決させる
      systemManagerRun =
        cmd:
        "nix run ${c.systemManager}#default -- ${cmd} --flake '.#${t.systemConfigName}'${
          if cmd == "switch" then " --sudo" else ""
        }";
    in
    {
      apps = {
        system-build = {
          type = "app";
          meta.description = "OS 層 (system-manager / NixOS) の toplevel をビルドする (副作用なし)";
          program = "${pkgs.writeShellScriptBin "system-build" ''
            set -eo pipefail

            ${c.shell.nixFeatureGuard}

            ${c.shell.detectHelpers}

            demoteToSudoUser "$@"

            require_nixbld

            ${linuxOnlyGuard}
            echo "  cmd    : system-build"
            echo ""
            if is_nixos; then
              ${pkgs.nix-output-monitor}/bin/nom build .#nixosConfigurations.${t.nixosConfigName}.config.system.build.toplevel
            else
              ${pkgs.nix-output-monitor}/bin/nom build .#systemConfigs.${t.systemConfigName}
            fi
          ''}/bin/system-build";
        };

        system-check = {
          type = "app";
          meta.description = "OS 層の dry-run。評価と生成物差分を確認する (sudo 不要)";
          program = "${pkgs.writeShellScriptBin "system-check" ''
            set -eo pipefail

            ${c.shell.nixFeatureGuard}

            ${c.shell.detectHelpers}

            demoteToSudoUser "$@"

            require_nixbld

            ${linuxOnlyGuard}
            echo "  cmd    : system-check"
            echo ""
            if is_nixos; then
              # dry-activate: 適用せずに差分のみ確認 (sudo 不要)
              nixos-rebuild dry-activate --flake .#${t.nixosConfigName}
            else
              ${systemManagerRun "build"}
            fi
          ''}/bin/system-check";
        };

        system-switch = {
          type = "app";
          meta.description = "OS 層 (/etc・systemd) を適用する (sudo 必要)";
          program = "${pkgs.writeShellScriptBin "system-switch" ''
            set -eo pipefail

            ${c.shell.nixFeatureGuard}

            ${c.shell.detectHelpers}

            demoteToSudoUser "$@"

            require_nixbld

            ${linuxOnlyGuard}
            echo "  cmd    : system-switch"
            echo ""
            if is_nixos; then
              echo "[!] nixos-rebuild switch を実行します (sudo 必要)"
              echo ""
              sudo_nix nixos-rebuild switch --flake .#${t.nixosConfigName}
            else
              echo "[!] /etc と systemd システムユニットを書き換えます"
              echo "    既存ファイルは .system-manager-backup として退避されます"
              echo ""
              ${systemManagerRun "switch"}
            fi
          ''}/bin/system-switch";
        };
      };
    };
}
