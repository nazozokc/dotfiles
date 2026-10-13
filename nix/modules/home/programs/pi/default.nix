{ config, ... }:

{
  dotfiles.programs.pi = {
    icon = "🥧";
    note = "settings / keybindings / codex-usage";
  };

  imports = [
    ./settings.nix
    ./keybindings.nix
  ];

  xdg.configFile."pi/agent/extensions/codex-usage.ts".source = ./extensions/codex-usage.ts;

  home.sessionVariables = {
    PI_CODING_AGENT_DIR = "${config.xdg.configHome}/pi/agent";
  };
}
