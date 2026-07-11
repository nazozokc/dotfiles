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
      pkgs.gh-poi
      pkgs.gh-notify
      pkgs.gh-do
    ];
  };
}
