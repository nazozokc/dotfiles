# nix/flake-parts/apps/switch.nix
# apps.switch — OS 自動判定でユーザー層と OS 層の適用
#
#   WSL   … home-manager のみ (OS 層は Windows 側 .wslconfig の管轄)
#   macOS … nix-darwin (nix-darwin が OS 層まで持つ)
#   Linux … home-manager → system-manager (OS 層・sudo 必要)
{ inputs, ... }:
let
  c = import ./common.nix { inherit inputs; };
in
{
  perSystem =
    { pkgs, system, ... }:
    let
      t = c.targetsFor system;
    in
    {
      apps.switch = {
        type = "app";
        meta.description = "OS 自動判定でユーザー層と OS 層を適用する";
        program = "${pkgs.writeShellScriptBin "switch" ''
          set -eo pipefail

          ${c.shell.nixFeatureGuard}

          ${c.shell.detectHelpers}

          require_nixbld

          # 事前チェック: flake の評価エラーを検出
          echo "[pre-flight] nix flake check --no-build ..."
          nix flake check --no-build
          echo ""

          if is_wsl; then
            echo "  system : WSL (x86_64)"
            echo "  target : .#${t.wslConfigName}"
            echo "  cmd    : switch"
            echo ""
            check_wslconfig
            nix run github:nix-community/home-manager -- switch --flake .#${t.wslConfigName} |& ${pkgs.nix-output-monitor}/bin/nom
            rebuild_ksycoca
          elif is_darwin; then
            echo "  system : ${t.sysLabel}"
            echo "  target : ${t.flakeTarget}"
            echo "  cmd    : switch"
            echo ""
            # sudo は既定で環境変数を捨てるため、NIX_CONFIG を引き継ぐ
            sudo_nix nix run nix-darwin -- switch --flake ${t.flakeTarget} |& ${pkgs.nix-output-monitor}/bin/nom
          else
            echo "  system : ${t.sysLabel}"
            echo "  target : ${t.flakeTarget}"
            echo "  cmd    : switch"
            echo ""
            nix run github:nix-community/home-manager -- switch --flake ${t.flakeTarget} |& ${pkgs.nix-output-monitor}/bin/nom

            # 世代切替で nix store のパスが変わる。ksycoca は mtime が
            # epoch 固定の store を変更検知できないため、明示再構築する。
            rebuild_ksycoca

            # ネイティブ Linux は OS 層 (system-manager) も適用する。
            # WSL は .wslconfig (Windows 側) の管轄なので対象外。
            # macOS は nix-darwin が OS 層まで持つため対象外。
            #
            # 順序: home-manager (ユーザー層) → system-manager (OS 層)。
            # sudo 認証が失敗してもユーザー層は適用済みになる。
            echo ""
            echo "  system : ${t.sysLabel}"
            echo "  target : .#systemConfigs.${t.systemConfigName}"
            echo "  cmd    : system-switch"
            echo ""
            echo "[!] OS 層を適用します (/etc と systemd システムユニット・sudo 必要)"
            echo ""
            nix run ${c.systemManagerRef}#default -- switch --flake '.#${t.systemConfigName}' --sudo
          fi
        ''}/bin/switch";
      };
    };
}
