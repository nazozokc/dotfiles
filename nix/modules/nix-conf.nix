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
