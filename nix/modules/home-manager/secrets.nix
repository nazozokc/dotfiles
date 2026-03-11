# nix/modules/home-manager/secrets.nix
# sops-nix によるシークレット管理
#
# 使い方:
#   1. age キー生成: age-keygen -o ~/.config/sops/age/keys.txt
#   2. .sops.yaml に公開鍵を登録
#   3. secrets/secrets.yaml を作成: sops secrets/secrets.yaml
#   4. nix run .#switch で反映
{ config, ... }:
{
  # sops の設定
  sops = {
    # age キーのパス（home-manager 管理外なので手動生成が必要）
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    defaultSopsFile = ../../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    # シークレット定義の例
    # secrets."github_token" = {};
    # secrets."openai_api_key" = {};
  };
}
