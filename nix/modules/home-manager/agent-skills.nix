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
    targets = {
      claude = {
        dest = ".claude/skills";
        structure = "link";
      };
      opencode = {
        dest = ".config/opencode/skills";
        structure = "link";
      };
      codex = {
        dest = ".config/codex/skills";
        structure = "link";
      };
      agents = {
        dest = ".agents/skills";
        structure = "link";
      };
    };
  };
}
