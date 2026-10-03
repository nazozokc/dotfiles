{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nazospkg.linuxPkgManager;
in
{
  options.nazospkg.linuxPkgManager = {
    enable = lib.mkEnableOption "Linux package manager setup (flatpak/others)";
  };

  config = lib.mkIf cfg.enable {
    system.activationScripts.linux-pkgmanager = {
      text = ''
                #!/usr/bin/env bash
                set -euo pipefail

                # WSL では system-manager switch は推奨されないためスキップ
                if [[ -n "''${WSL_DISTRO_NAME:-}" ]] || [[ -e /proc/sys/fs/binfmt_misc/WSLInterop ]]; then
                  echo "[linux-pkgmanager] WSL detected, skipping."
                  exit 0
                fi

                echo "[linux-pkgmanager] Applying Linux package manager configuration..."

                if command -v flatpak >/dev/null 2>&1; then
                  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
                fi

                if command -v flatpak >/dev/null 2>&1; then
                  while IFS= read -r id; do
                    [[ -z "$id" ]] && continue
                    flatpak info "$id" >/dev/null 2>&1 || flatpak install -y --noninteractive flathub "$id" || true
                  done <<'EOF'
        com.mattjakeman.ExtensionManager
        com.github.tchx84.Flatseal
        com.github.rafostar.Clapper
        EOF
                fi

                echo "[linux-pkgmanager] Done."
      '';
      deps = [ ];
    };
  };
}
