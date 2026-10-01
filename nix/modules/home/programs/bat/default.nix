{
  ...
}:
{
  dotfiles.programs.bat = {
    icon = "🦇";
    note = "TwoDark / less pager";
  };

  programs.bat = {
    enable = true;

    # Rendered to ~/.config/bat/config by home-manager, one `--flag=value`
    # pair per option. Values must be strings: `tabs` has to be "2", not 2.
    config = {
      theme = "TwoDark";
      pager = "less -FR";
      style = "numbers,changes,header";
      tabs = "2";
    };
  };
}
