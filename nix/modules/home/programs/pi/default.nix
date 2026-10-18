{ config, dotfilesDir, ... }:

let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  dotfiles.programs.pi = {
    icon = "🥧";
    note = "settings / keybindings / codex-usage / editor / nazozokc-pi / agent-modes / parallel-agents / git";
  };

  imports = [
    ./settings.nix
    ./keybindings.nix
  ];

  xdg.configFile = {
    "pi/agent/extensions/codex-usage.ts".source = ./extensions/codex-usage.ts;
    "pi/agent/extensions/editor.ts".source = ./extensions/editor.ts;
    "pi/agent/extensions/nazozokc-pi".source = ./extensions/nazozokc-pi;
    "pi/agent/extensions/agent-modes".source = ./extensions/agent-modes;
    "pi/agent/extensions/parallel-agents".source = ./extensions/parallel-agents;
    "pi/agent/extensions/git".source = ./extensions/git;
    "pi/agent/extensions/shared".source = ./extensions/shared;
  };

  # グローバル指示
  home.file.".pi/agent/AGENTS.md" = {
    source = link "${dotfilesDir}/pi/AGENTS.md";
  };

  home.sessionVariables = {
    PI_CODING_AGENT_DIR = "${config.xdg.configHome}/pi/agent";
  };
}
