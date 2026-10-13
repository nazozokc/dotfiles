{ config, ... }:

{
  dotfiles.programs.pi = {
    icon = "🥧";
    note = "settings / keybindings / codex-usage / editor / nazozokc-pi";
  };

  imports = [
    ./settings.nix
    ./keybindings.nix
  ];

  xdg.configFile."pi/agent/extensions/codex-usage.ts".source = ./extensions/codex-usage.ts;
  xdg.configFile."pi/agent/extensions/editor.ts".source = ./extensions/editor.ts;
  xdg.configFile."pi/agent/extensions/nazozokc-pi".source = ./extensions/nazozokc-pi;

  home.sessionVariables = {
    PI_CODING_AGENT_DIR = "${config.xdg.configHome}/pi/agent";
  };
}
