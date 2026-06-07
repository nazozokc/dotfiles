# nix/modules/linux/hyprland/default.nix
# Hyprland: dynamic tiling Wayland compositor
# Linux (non-NixOS) でのみ有効
{
  config,
  pkgs,
  lib,
  ...
}:

{
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    xwayland.enable = true;
    systemd.enable = true;

    # hyprlang 形式（安定優先）
    # 必要に応じて Lua (v0.55+) に移行可能
    configType = "hyprlang";

    settings = {
      "$mod" = "SUPER";

      # ------------------------------------------------------------------
      # Monitor
      # ------------------------------------------------------------------
      monitor = [
        "eDP-1, 2560x1600@165, 0x0, 1"
        # 外部モニターは必要に応じて追加
      ];

      # ------------------------------------------------------------------
      # Autostart
      # ------------------------------------------------------------------
      exec-once = [
        "fcitx5 -d"
        "waybar"
        "hyprpaper"
        "hypridle"
        "dunst"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];

      # ------------------------------------------------------------------
      # Keybindings
      # 設計方針（wezterm / nvim のキーバインドパターンを反映）
      #   SUPER (Win)  : 主修飾。WM 専用
      #   Ctrl単体     : nvim 用に空ける
      #   CTRL|SHIFT   : wezterm 用に空ける（重複防止）
      #   ALT          : 誤操作防止の追加修飾（リサイズ等）
      #   h/j/k/l      : vim 方向キー → ウィンドウフォーカス/移動
      #   Space        : nvim leader (`mapleader = " "`) 用に空ける
      # ------------------------------------------------------------------
      bind = [
        # ---- アプリ起動 ----
        "$mod, Return, exec, wezterm"
        "$mod, E, exec, nvim"
        "$mod, F, exec, firefox"
        "$mod, SPACE, exec, wofi --show drun"
        "$mod, R, exec, wofi --show run"

        # ---- ウィンドウ操作 ----
        "$mod, Q, killactive,"
        "$mod, V, togglefloating,"
        "$mod, F11, fullscreen,"
        "$mod, P, pseudo,"
        "$mod SHIFT, P, togglesplit,"

        # ---- フォーカス移動（vim 方向キー） ----
        "$mod, H, movefocus, l"
        "$mod, J, movefocus, d"
        "$mod, K, movefocus, u"
        "$mod, L, movefocus, r"

        # ---- ウィンドウ移動 ----
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, J, movewindow, d"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, L, movewindow, r"

        # ---- ワークスペース ----
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # ---- スクリーンショット ----
        ", Print, exec, hyprshot -m region"

        # ---- 画面ロック ----
        "$mod, L, exec, hyprlock"
      ];

      # リサイズ（ALT 追加で誤操作防止）
      binde = [
        "$mod ALT, H, resizeactive, -10 0"
        "$mod ALT, L, resizeactive, 10 0"
        "$mod ALT, K, resizeactive, 0 -10"
        "$mod ALT, J, resizeactive, 0 10"
      ];

      # マウスバインディング
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # ------------------------------------------------------------------
      # Look & Feel
      # ------------------------------------------------------------------
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(0077ff88) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
        cursor_inactive_timeout = 3;
        no_cursor_warps = false;
      };

      decoration = {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = 0.9;
        fullscreen_opacity = 1.0;

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          new_optimizations = true;
          noise = 0.01;
          contrast = 0.9;
          brightness = 1.0;
        };

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "easeOutQuint, 0.23, 1, 0.32, 1"
          "easeInOutCubic, 0.65, 0, 0.35, 1"
        ];
        animation = [
          "windows, 1, 7, easeOutQuint"
          "windowsOut, 1, 7, easeOutQuint, popin 80%"
          "fade, 1, 7, easeInOutCubic"
          "workspaces, 1, 6, easeOutQuint, slide"
          "border, 1, 10, easeOutQuint"
          "borderangle, 1, 8, easeOutQuint"
        ];
      };

      # ------------------------------------------------------------------
      # Input
      # ------------------------------------------------------------------
      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_options = "ctrl:nocaps";
        follow_mouse = 1;
        mouse_refocus = false;
        sensitivity = 0;

        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          clickfinger_behavior = true;
          middle_button_emulation = false;
          tap-to-click = true;
          drag_lock = false;
        };
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
      };

      # ------------------------------------------------------------------
      # Misc
      # ------------------------------------------------------------------
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 1;
        vfr = true;
        vrr = 0;
      };

      # ------------------------------------------------------------------
      # Window Rules
      # ------------------------------------------------------------------
      windowrule = [
        "float, class:^(pavucontrol)$"
        "float, class:^(blueman-manager)$"
        "center, class:^(pavucontrol)$"
        "size 800 600, class:^(pavucontrol)$"
        "float, title:^(Open File)$"
        "float, title:^(File Operation Progress)$"
        "opacity 0.95, class:^(wezterm)$"
      ];
    };
  };

  # ---------------------------------------------------------------------------
  # Hyprland eco-system packages
  # ---------------------------------------------------------------------------
  home.packages = with pkgs; [
    hyprlock # 画面ロック
    hypridle # idle 管理
    hyprpaper # 壁紙
    hyprshot # スクリーンショット
    waybar # ステータスバー
    wofi # ランチャー
    dunst # 通知デーモン
    cliphist # クリップボード管理（Wayland）
    brightnessctl # 輝度調整
    pamixer # 音量調整
    networkmanagerapplet # ネットワーク管理トレイ
    libnotify # notify-send
  ];
}
