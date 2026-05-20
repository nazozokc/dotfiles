{ ... }:
{
  programs.bat = {
    enable = true;

    config = {
      theme = "TwoDark";
      pager = "less -FR";
      style = "numbers,changes,header";
      tabs = "2";
    };
  };
}
