{
  pkgs,
  ...
}:
{
  programs.gh = {
    enable = true;

    extensions = [
      # Extensions available in nixpkgs
      pkgs.gh-markdown-preview
      pkgs.gh-dash
      pkgs.gh-actions-cache
      pkgs.gh-poi
      pkgs.gh-notify
      pkgs.gh-do

    ];
  };
}
