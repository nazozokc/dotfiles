{ pkgs, ... }:
{
  # ===== GTK theme =====
  gtk = {
    enable = true;

    theme = {
      name = "Catppuccin-Mocha-Standard-Blue-Dark";
      package = pkgs.catppuccin-gtk;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 10;
    };
  };

  # ===== Qt theme (follow GTK) =====
  qt = {
    enable = true;
    platformTheme = "gtk";
    style = {
      name = "adwaita";
      package = pkgs.adwaita-qt;
    };
  };
}
