{ config, pkgs, ... }:
{
  systemd.user.services = {
    # ===== nix-store-gc — Weekly Nix store garbage collection =====
    nix-store-gc = {
      Unit = {
        Description = "Nix store garbage collection";
        Documentation = "man:nix-store-gc";
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.nix}/bin/nix-store --gc";
        Nice = 19;
        IOSchedulingClass = "idle";
      };
    };
  };

  systemd.user.timers = {
    nix-store-gc = {
      Unit = {
        Description = "Weekly Nix store GC";
      };

      Timer = {
        OnCalendar = "weekly";
        Persistent = true;
        RandomizedDelaySec = "6h";
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
