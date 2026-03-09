# nix/modules/home-manager/agent-skills.nix
{ ... }:
{
  programs.agent-skills = {
    enable = true;

    sources.local = {
      path = ./../../../agents/skills; # dotfiles内のskillsディレクトリ
      subdir = ".";
    };

    skills.enableAll = [ "local" ];

    targets.claude = {
      dest = ".config/claude/skills";
      structure = "link";
    };
  };
}
