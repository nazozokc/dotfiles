{
  config,
  pkgs,
  lib,
  ...
}:

let
  homeDir = config.home.homeDirectory;
  secretsFile = ../../../../secrets/common.yaml;
  hasSecretsFile = builtins.pathExists secretsFile;
in
{
  sops = lib.mkIf pkgs.stdenv.isLinux {
    age = {
      keyFile = "${homeDir}/.config/sops/age/keys.txt";
      generateKey = false;
    };

    # secrets/common.yaml がある時だけ読み込む
    defaultSopsFile = lib.mkIf hasSecretsFile secretsFile;

    # 各 secret は Linux / WSL 共通で ~/.config/secrets に展開
    # NOTE: 実値は secrets/common.yaml を sops で暗号化して管理する
    secrets = lib.optionalAttrs hasSecretsFile {
      "api/github_token" = {
        path = "${homeDir}/.config/secrets/github_token";
        mode = "0400";
      };

      "api/openai_api_key" = {
        path = "${homeDir}/.config/secrets/openai_api_key";
        mode = "0400";
      };

      "api/anthropic_api_key" = {
        path = "${homeDir}/.config/secrets/anthropic_api_key";
        mode = "0400";
      };
    };
  };
}
