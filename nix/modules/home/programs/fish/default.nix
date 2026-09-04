{
  pkgs,
  lib,
  dotfilesDir,
  ...
}:
{
  programs.fish = {
    enable = true;

    # fish は起動時に conf.d/ を自動で sourced するため、
    # interactiveShellInit で手動 sourcing すると二重実行となりエラーの原因になる。
    # ここでは空のままにする。

    # Plugins managed by Nix (home-manager format)
    plugins = [
      {
        name = "fisher";
        src = pkgs.fisher;
      }
    ];
  };
}
