{
  dotfilesDir,
  ...
}:
{
  programs.starship = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    # Configuration is in starship/starship.toml (shared across platforms)
    # The file is deployed below as a symlink
  };

  home.file.".config/starship.toml".source = "${dotfilesDir}/starship/starship.toml";
}
