{ config, ... }:

{
  dotfiles.programs.pi = {
    icon = "🥧";
    note = "settings / keybindings / codex-usage / editor / nazozokc-pi / agent-modes / parallel-agents / git";
  };

  imports = [
    ./settings.nix
    ./keybindings.nix
  ];

  xdg.configFile."pi/agent/extensions/codex-usage.ts".source = ./extensions/codex-usage.ts;
  xdg.configFile."pi/agent/extensions/editor.ts".source = ./extensions/editor.ts;
  xdg.configFile."pi/agent/extensions/nazozokc-pi".source = ./extensions/nazozokc-pi;
  xdg.configFile."pi/agent/extensions/agent-modes".source = ./extensions/agent-modes;
  xdg.configFile."pi/agent/extensions/parallel-agents".source = ./extensions/parallel-agents;
  xdg.configFile."pi/agent/extensions/git".source = ./extensions/git;
  xdg.configFile."pi/agent/extensions/shared".source = ./extensions/shared;

  # グローバル指示
  home.file.".pi/agent/AGENTS.md" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ghq/github.com/nazozokc/dotfiles/pi/AGENTS.md";
  };

  home.sessionVariables = {
    PI_CODING_AGENT_DIR = "${config.xdg.configHome}/pi/agent";
  };
}
