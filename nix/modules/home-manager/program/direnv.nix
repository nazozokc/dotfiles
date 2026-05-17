{ pkgs, ... }:
{
  programs.direnv = {
    enable = true;

    nix-direnv.enable = true;

    silent = true;

    config = {
      global = {
        load_dotenv = true;
        strict_env = false;
        warn_timeout = "5m";
      };
    };

    stdlib = ''
      # Hide the "direnv: using ..." messages
      hide_use() {
        local new=''${NIX_BUILD_TOP:-}
        if [[ -n $new ]]; then
          local old=''${DIRENV_DIFF:-}
          export DIRENV_DIFF=$old
        fi
      }

      # Show only the diff of environment variables
      show_env_diff() {
        if [[ -n ''${DIRENV_DIFF:-} ]]; then
          local old=$(echo "$DIRENV_DIFF" | jq -r '.old | keys[]' 2>/dev/null)
          local new=$(echo "$DIRENV_DIFF" | jq -r '.new | keys[]' 2>/dev/null)
          diff <(echo "$old") <(echo "$new") | grep -E '^[<>]' || true
        fi
      }

      # Auto-load nixpkgs if flake.nix exists
      use_flake() {
        if [[ -f flake.nix ]]; then
          use flake
        elif [[ -f shell.nix ]]; then
          use nix
        fi
      }
    '';
  };
}
