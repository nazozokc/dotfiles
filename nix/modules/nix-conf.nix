# nix/modules/nix-conf.nix
# 全プラットフォーム共通の /etc/nix/nix.conf 設定
# macOS (nix-darwin) / Linux / WSL すべてで同じ設定を適用する
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
