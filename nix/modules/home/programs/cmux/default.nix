{ ... }:

{
  xdg.configFile."cmux/cmux.json".text = ''
    {
      "$schema": "https://raw.githubusercontent.com/manaflow-ai/cmux/main/web/data/cmux.schema.json",
      "schemaVersion": 1,

      "terminal": {
        "showScrollBar": false,
        "copyOnSelect": true
      },

      "shortcuts": {
        "bindings": {
          "toggleSidebar": "cmd+b",

          "newTab": "ctrl+shift+t",
          "closeTab": "ctrl+shift+w",

          "splitRight": "ctrl+shift+e",
          "splitDown": "ctrl+shift+d",
          "closePane": "ctrl+shift+q",
          "toggleSplitZoom": "ctrl+shift+z",

          "focusPaneLeft": "ctrl+shift+h",
          "focusPaneDown": "ctrl+shift+j",
          "focusPaneUp": "ctrl+shift+k",
          "focusPaneRight": "ctrl+shift+l",

          "resizeSplitLeft": "ctrl+shift+alt+h",
          "resizeSplitDown": "ctrl+shift+alt+j",
          "resizeSplitUp": "ctrl+shift+alt+k",
          "resizeSplitRight": "ctrl+shift+alt+l",

          "nextTab": "ctrl+shift+]",
          "previousTab": "ctrl+shift+[",

          "toggleFullscreen": "ctrl+shift+enter",
          "newWindow": "ctrl+shift+n",

          "commandPalette": "ctrl+shift+p"
        }
      }
    }
  '';
}
