{ ... }:
{
  # ===== Default applications (mimeapps) =====
  xdg = {
    mime.enable = true;

    mime.defaultApplications = {
      # Browser
      "text/html" = [ "google-chrome.desktop" ];
      "x-scheme-handler/http" = [ "google-chrome.desktop" ];
      "x-scheme-handler/https" = [ "google-chrome.desktop" ];
      "x-scheme-handler/about" = [ "google-chrome.desktop" ];
      "x-scheme-handler/unknown" = [ "google-chrome.desktop" ];

      # Editor
      "text/plain" = [ "nvim.desktop" ];

      # Images
      "image/png" = [ "gwenview.desktop" ];
      "image/jpeg" = [ "gwenview.desktop" ];

      # Directory
      "inode/directory" = [ "dolphin.desktop" ];

      # Video
      "video/mp4" = [ "vlc.desktop" ];
      "video/x-matroska" = [ "vlc.desktop" ];

      # Audio
      "audio/mpeg" = [ "vlc.desktop" ];
      "audio/flac" = [ "vlc.desktop" ];

      # PDF
      "application/pdf" = [ "okular.desktop" ];

      # Archive
      "application/zip" = [ "ark.desktop" ];
      "application/x-tar" = [ "ark.desktop" ];
      "application/gzip" = [ "ark.desktop" ];
    };
  };
}
