# nix/modules/home-manager/agent-skills.nix
{ ... }:
{
  programs.agent-skills = {
    enable = true;
    sources.local = {
      path = ./../../../agents/skills;
      subdir = ".";
    };
    skills.enableAll = [ "local" ];
    targets.claude = {
      dest = ".config/claude/skills";
      structure = "link";
    };
    targets.opencode = {
      dest = ".config/opencode/skills";
      structure = "link";
    };
    targets.codex = {
      dest = ".config/codex/skills";
      structure = "link";
    };
    targets.agents = {
      dest = ".agents/skills";
      structure = "link";
    };
  };
}
