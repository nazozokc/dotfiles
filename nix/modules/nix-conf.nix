# nix/modules/nix-conf.nix
# ユーザー単位の nix 設定 (home-manager 経由で ~/.config/nix/nix.conf に出力される)
# macOS (nix-darwin) / Linux / WSL すべてで同じ設定を適用する
#
# 役割分担:
#   - ~/.config/nix/nix.conf … このファイル (ユーザー別の上書き)
#   - /etc/nix/nix.conf       … nix/modules/system/nix-conf.nix (system-manager) — システム既定値
#
# Nix はユーザー設定 (NIX_USER_CONF_FILES) でシステム設定 (/etc/nix/nix.conf) を
# 上書きするため、両方を書くのは正しい構成。
#
# ただし auto-optimise-store / always-allow-substitutes は Nix の restricted setting。
# multi-user インストール (/etc/nix/nix.conf に trusted-users が無い環境) では
# クライアントが trusted user で無いため、nix コマンドごとに
#   warning: ignoring the client-specified setting 'auto-optimise-store', ...
# を出して設定が捨てられる。Store の自動最適化も働かない。
#
# 単一ユーザーインストール (macOS の --no-daemon など) では効くため設定は残す。
# multi-user で効かせたい場合は /etc/nix/nix.conf の trusted-users に
# username を追加する必要がある (OS 層の管轄)。
{
  pkgs,
  username,
  ...
}:

{
  nix.package = pkgs.nix;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    always-allow-substitutes = true;
    max-jobs = "auto";
    trusted-users = [ username ];
  };
}
