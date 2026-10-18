# nix/flake-parts/apps/config-update.nix
# apps.config-update — ローカル編集を nix store の config へ反映する
#
# #switch との差分:
#   - `nix flake check --no-build` を走らせない
#   - OS 層 (system-manager / nix-darwin) を触らない = sudo 不要
#   - home-manager (ユーザー層) の再適用だけする
#
# home-manager activation が対象なので、symlink の 2 系統が両方更新される:
#   - mkOutOfStoreSymlink (dotfilesDir = self.outPath の store スナップショット)
#   - home-manager 生成物 (git / starship / opencode.json など)
#
# 「最新版」はローカル編集の反映のみ。git pull も flake.lock 更新もしない。
{ inputs, ... }:
let
  c = import ./common.nix { inherit inputs; };
in
{
  perSystem =
    { pkgs, system, ... }:
    let
      t = c.targetsFor system;
      username = c.identity.username;
    in
    {
      apps.config-update = {
        type = "app";
        meta.description = "ローカル編集を nix store の config へ反映する (home-manager のみ・sudo 不要)";
        program = "${pkgs.writeShellScriptBin "config-update" ''
          set -eo pipefail

          ${c.shell.nixFeatureGuard}

          ${c.shell.detectHelpers}

          # activationPackage のビルドで store へ書くため警告のみ (switch と同じ扱い)
          warn_nixbld

          ${t.printInfo "config-update"}

          # -------------------------------------------------------------------
          # 1. 状態確認
          # -------------------------------------------------------------------
          echo "[1/3] 状態確認"

          # flake ソースは git 追跡分だけ store へコピーされる。未追跡ファイルは
          # どの symlink 先にも現れない (= 反映されない) ので、その場で警告する。
          untracked=$(git status --porcelain 2>/dev/null | grep '^??' || true)
          if [ -n "$untracked" ]; then
            echo "[!] 未追跡ファイルは nix store に含まれません (反映されません):"
            echo "$untracked" | sed 's/^/      /'
            echo "    対処: git add <file> してから再実行してください"
          fi
          echo ""

          # -------------------------------------------------------------------
          # 2. 反映
          # -------------------------------------------------------------------
          echo "[2/3] home-manager を再適用 (ユーザー層のみ・sudo 不要)"
          if is_wsl; then
            # nix が適用できない Windows 側 .wslconfig のずれだけ先に検出
            check_wslconfig
            nix run github:nix-community/home-manager -- switch --flake .#${t.wslConfigName} |& ${pkgs.nix-output-monitor}/bin/nom
            rebuild_ksycoca
          elif is_darwin; then
            # darwin には standalone の homeConfigurations が無いので、
            # darwinConfigurations に組み込まれた activationPackage を直接 activate
            # する (nix-darwin の OS 層は触らない)。
            # --print-out-paths は stdout、ビルドログは stderr。nom は stdout を
            # エスケープで汚して capture を壊すので併用しない (実測済み)。
            out=$(nix build --no-link --print-out-paths \
              ".#darwinConfigurations.${t.darwinConfigName}.config.home-manager.users.${username}.activationPackage")
            "$out/activate"
          else
            nix run github:nix-community/home-manager -- switch --flake ${t.flakeTarget} |& ${pkgs.nix-output-monitor}/bin/nom
            rebuild_ksycoca
          fi
          echo ""

          # -------------------------------------------------------------------
          # 3. 完了
          # -------------------------------------------------------------------
          echo "[3/3] 完了"
          echo "      store の config と symlink を最新化しました"
          echo "      起動中のアプリは旧設定のままです (opencode 等は再起動し新規セッションを開くこと)"
        ''}/bin/config-update";
      };
    };
}
