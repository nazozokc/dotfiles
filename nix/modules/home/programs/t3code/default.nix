# nix/modules/home/programs/t3code/default.nix
# T3 Code: OpenCode / Big Pickle を既定モデルに、wezterm 風のキーバインドを設定する
{ pkgs, ... }:

{
  dotfiles.programs.t3code = {
    icon = "💻";
    note = "opencode / big-pickle + wezterm keybindings";
  };

  programs.t3code = {
    enable = true;

    # 既定のラッパーは codex しか PATH に入れないので opencode を追加する
    package = pkgs.t3code.override {
      enableOpencode = true;
    };

    userSettings = {
      # 新規スレッドの既定モデル
      defaultModelSelection = {
        instanceId = "opencode";
        model = "opencode/big-pickle";
      };

      # OpenCode プロバイダは既定で無効なので明示的に有効化する
      providerInstances.opencode = {
        driver = "opencode";
        enabled = true;
        config = {
          enabled = true;
          binaryPath = "opencode";
        };
      };
    };

    clientSettings = {
      favorites = [
        {
          provider = "opencode";
          model = "opencode/big-pickle";
        }
      ];
    };

    # wezterm/config/keys.lua の Ctrl+Shift 系を T3 Code のコマンドに対応させる。
    # mod は Linux で Ctrl だが、wezterm と同じ ctrl+shift を明示的に指定する。
    keybindings = [
      # タブ: 新規 / クローズ (wezterm Ctrl+Shift+T / W)
      {
        key = "ctrl+shift+t";
        command = "terminal.new";
        when = "terminalFocus";
      }
      {
        key = "ctrl+shift+t";
        command = "chat.new";
        when = "!terminalFocus";
      }
      {
        key = "ctrl+shift+w";
        command = "terminal.close";
        when = "terminalFocus";
      }
      {
        key = "ctrl+shift+w";
        command = "rightPanel.close";
        when = "rightPanelOpen && !terminalFocus";
      }

      # タブ移動: [ = prev / ] = next (wezterm Ctrl+Shift+[ / ])
      {
        key = "ctrl+shift+[";
        command = "thread.previous";
      }
      {
        key = "ctrl+shift+]";
        command = "thread.next";
      }

      # ペイン分割・消去・ズーム (wezterm Ctrl+Shift+E / D / Q / Z)
      {
        key = "ctrl+shift+e";
        command = "terminal.split";
        when = "terminalFocus";
      }
      {
        key = "ctrl+shift+d";
        command = "terminal.splitVertical";
        when = "terminalFocus";
      }
      {
        key = "ctrl+shift+q";
        command = "terminal.close";
        when = "terminalFocus";
      }
      {
        key = "ctrl+shift+z";
        command = "rightPanel.toggleMaximized";
        when = "rightPanelOpen";
      }

      # ウィンドウ / コマンドパレット (wezterm Ctrl+Shift+N / P)
      {
        key = "ctrl+shift+n";
        command = "chat.newWithoutProject";
        when = "!terminalFocus";
      }
      {
        key = "ctrl+shift+p";
        command = "commandPalette.toggle";
        when = "!terminalFocus";
      }

      # 透過率サイクル (wezterm Ctrl+Shift+F) の代わりに外観を切り替える
      {
        key = "ctrl+shift+f";
        command = "appearance.cycle";
        when = "!terminalFocus";
      }
    ];
  };
}
