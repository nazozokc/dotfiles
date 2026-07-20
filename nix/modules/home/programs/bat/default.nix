{
  dotfilesDir,
  ...
}:
{
  programs.bat = {
    enable = true;

    # Configuration is in bat/config (shared across platforms)
    # config = {};
  };

  home.file.".config/bat/config".source = "${dotfilesDir}/bat/config";
}
