{
  dotfilesDir,
  ...
}:
{
  programs.starship = {
    enable = true;

    # home-manager only injects starship init into a shell that it itself
    # enables. programs.bash and programs.zsh are both enable = false in all
    # five configurations, so these two flags were no-ops that just looked
    # like they were doing something. zsh/zshrc runs `starship init zsh`
    # itself, and bash/bashrc keeps a hand-written PS1.
    enableBashIntegration = false;
    enableZshIntegration = false;

    # fish is the only shell home-manager enables here, and it uses a custom
    # fish_prompt.fish. Turning this on would replace that prompt.
    enableFishIntegration = false;

    # Configuration is in starship/starship.toml (shared across platforms)
    # The file is deployed below as a symlink
  };

  home.file.".config/starship.toml".source = "${dotfilesDir}/starship/starship.toml";
}
