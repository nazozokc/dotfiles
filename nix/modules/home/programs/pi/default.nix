{ config, ... }:

{
  dotfiles.programs.pi = {
    icon = "🥧";
    note = "settings / keybindings / codex-usage / editor";
  };

  imports = [
    ./settings.nix
    ./keybindings.nix
  ];

  xdg.configFile."pi/agent/extensions/codex-usage.ts".source = ./extensions/codex-usage.ts;
  xdg.configFile."pi/agent/extensions/editor.ts".source = ./extensions/editor.ts;

  home.sessionVariables = {
    PI_CODING_AGENT_DIR = "${config.xdg.configHome}/pi/agent";
  };
}
