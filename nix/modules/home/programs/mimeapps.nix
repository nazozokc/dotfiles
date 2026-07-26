{ ... }:
{
  # Force overwrite existing file managed by home-manager's xdg.mimeApps module
  xdg.configFile."mimeapps.list".force = true;

  # ===== Default applications (mimeapps) =====
  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      # Browser
      "text/html" = [ "google-chrome.desktop" ];
      "x-scheme-handler/http" = [ "google-chrome.desktop" ];
      "x-scheme-handler/https" = [ "google-chrome.desktop" ];
      "x-scheme-handler/about" = [ "google-chrome.desktop" ];
      "x-scheme-handler/unknown" = [ "google-chrome.desktop" ];

      # Editor
      "text/plain" = [ "nvim.desktop" ];

      # Video
      "video/mp4" = [ "vlc.desktop" ];
      "video/x-matroska" = [ "vlc.desktop" ];

      # Audio
      "audio/mpeg" = [ "vlc.desktop" ];
      "audio/flac" = [ "vlc.desktop" ];

    };
  };
}
