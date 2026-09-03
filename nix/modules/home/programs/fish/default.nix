{
  pkgs,
  lib,
  dotfilesDir,
  ...
}:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Load all conf.d files
      for file in $__fish_config_dir/conf.d/*.fish
        source $file
      end
    '';

    # Plugins managed by Nix (home-manager format)
    plugins = [
      {
        name = "fisher";
        src = pkgs.fisher;
      }
      # fishna - repository not found on GitHub (ryoppippi/fishna returns 404)
      # Uncomment and fix when the correct repository is available:
      # {
      #   name = "fishna";
      #   src = pkgs.fishna;
      # }
    ];
  };
}
