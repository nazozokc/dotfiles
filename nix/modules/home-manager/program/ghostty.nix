{
  programs.ghostty = {
    enable = true;

    settings = {
      # ====================
      # Font
      # ====================
      font-family = "JetBrainsMono Nerd Font";
      font-size = 13;
      adjust-cell-height = "5%";
      adjust-cell-width = "0%";

      # ====================
      # Colors
      # ====================
      background-opacity = 0.90;
      foreground = "#C5C9C5";
      background = "#181616";
      cursor-color = "#C5C9C5";
      selection-foreground = "#C5C9C5";
      selection-background = "#2D4F67";

      # ANSI colors
      palette = [
        "0=#0D0C0C"
        "1=#C4746E"
        "2=#8A9A7B"
        "3=#C4B28A"
        "4=#8BA4B0"
        "5=#A292A3"
        "6=#8EA4A2"
        "7=#C5C9C5"
        "8=#A6A69C"
        "9=#E46876"
        "10=#87A987"
        "11=#E6C384"
        "12=#7FB4CA"
        "13=#938AA9"
        "14=#7AA89F"
        "15=#C5C9C5"
      ];

      # ====================
      # Window
      # ====================
      window-padding-x = 6;
      window-padding-y = 4;
      window-decoration = true;

      # ====================
      # Mouse
      # ====================
      mouse-hide-while-typing = true;

      # ====================
      # Tabs
      # ====================
      title = "$PWD";

      # ====================
      # Keybinds
      # ====================
      keybind = [
        "ctrl+shift+t=new_tab"
        "ctrl+shift+w=close_tab"
        "ctrl+shift+q=close_surface"
        "ctrl+shift+e=new_split:right"
        "ctrl+shift+d=new_split:down"
        "ctrl+shift+z=toggle_split_zoom"
        "ctrl+shift+page_up=previous_tab"
        "ctrl+shift+page_down=next_tab"
        "ctrl+shift+enter=toggle_fullscreen"
        "ctrl+shift+n=new_window"
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"
        "ctrl+shift+r=reload_config"
        # Pane navigation (vim-style)
        "ctrl+shift+h=goto_split:left"
        "ctrl+shift+j=goto_split:bottom"
        "ctrl+shift+k=goto_split:top"
        "ctrl+shift+l=goto_split:right"
        # Pane resize (vim-style)
        "ctrl+shift+alt+h=resize_split:left,20"
        "ctrl+shift+alt+j=resize_split:down,20"
        "ctrl+shift+alt+k=resize_split:up,20"
        "ctrl+shift+alt+l=resize_split:right,20"
      ];
    };
  };
}
