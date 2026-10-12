{ config, ... }:

{
  dotfiles.programs.pi = {
    icon = "🥧";
    note = "settings / keybindings";
  };

  imports = [
    ./settings.nix
    ./keybindings.nix
    ./plugin.nix
  ];

  home.sessionVariables = {
    PI_CODING_AGENT_DIR = "${config.xdg.configHome}/pi/agent";
  };
}
