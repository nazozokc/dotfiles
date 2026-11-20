{ pkgs, lib, ... }:
let
  aiConfig = import ../../../../lib/ai-config.nix;

  # 無いモデルだけ pull する。起動のたびに再 download しない。
  pullScript = pkgs.writeShellScript "ollama-pull-models" ''
    set -eu
    ollama="${pkgs.ollama}/bin/ollama"

    # サーバーが localhost で listen するまで待つ (最大 30s)
    for _ in $(seq 1 30); do
      if "$ollama" list >/dev/null 2>&1; then
        break
      fi
      sleep 1
    done

    ${lib.concatMapStringsSep "\n" (model: ''
      if "$ollama" list 2>/dev/null | awk -v m=${lib.escapeShellArg model} '$1 == m { found = 1 } END { exit !found }'; then
        printf 'ollama: %s は既に存在します\n' ${lib.escapeShellArg model}
      else
        printf 'ollama: %s を pull します\n' ${lib.escapeShellArg model}
        "$ollama" pull ${lib.escapeShellArg model}
      fi
    '') aiConfig.ollamaModels}
  '';
in
{
  dotfiles.programs.ollama = {
    icon = "🦙";
    note = "127.0.0.1:11434 / モデル自動pull";
  };

  services.ollama = {
    enable = true;
    # acceleration = null;  # null: デフォルト, "cuda": NVIDIA, "rocm": AMD
    host = "127.0.0.1";
    port = 11434;
  };

  # ollama.service の起動後に、無いモデルだけ pull する
  systemd.user.services.ollama-models = {
    Unit = {
      Description = "Pull configured Ollama models";
      After = [ "ollama.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = pullScript;
    };
  };
  systemd.user.services.ollama.unitConfig.Wants = [ "ollama-models.service" ];
}
