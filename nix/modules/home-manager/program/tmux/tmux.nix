{ config, pkgs, ... }:
{
  programs.tmux = {
    enable = true;

    clock24 = true;
    mouse = true;
    keyMode = "vi";
    prefix = "C-a";
    terminal = "tmux-256color";
    historyLimit = 100000;

    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.resurrect
      tmuxPlugins.continuum
      tmuxPlugins.yank
    ];

    extraConfig = ''
      # ===== Pane splitting =====
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # ===== Smart pane switching =====
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # ===== Pane management =====
      bind Tab next-pane
      bind C-o rotate-window
      bind Space next-layout

      # ===== Open new window with current pane's cwd =====
      bind c new-window -c "#{pane_current_path}"

      # ===== Copy mode with vi =====
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # ===== Reload config =====
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

      # ===== Window numbering starts at 1 =====
      set -g base-index 1
      set -g pane-base-index 1

      # ===== Disable automatic window renaming =====
      set -g automatic-rename off
      set -g allow-rename off

      # ===== Activity monitoring =====
      set -g monitor-activity on
      set -g visual-activity on

      # ===== Kanagawa Dragon Status Bar =====
      set -g status-position bottom
      set -g status-justify left
      set -g status-style "bg=#1F1F28,fg=#C8C093"
      set -g status-left-length 40
      set -g status-right-length 60

      # Status left: session name
      set -g status-left "#[fg=#1F1F28,bg=#7e9cd8,bold] #S #[fg=#7e9cd8,bg=#1F1F28,nobold]"

      # Status right: date/time
      set -g status-right "#[fg=#1F1F28,bg=#54546D,nobold]#[fg=#C8C093,bg=#54546D] %Y-%m-%d  %H:%M #[fg=#54546D,bg=#1F1F28,nobold]"

      # Window status
      set -g window-status-format "#[fg=#54546D]#[fg=#C8C093,bg=#54546D] #I:#W #[fg=#54546D]"
      set -g window-status-current-format "#[fg=#1F1F28,bg=#7e9cd8,nobold]#[fg=#1F1F28,bg=#7e9cd8,bold] #I:#W #[fg=#7e9cd8,bg=#1F1F28,nobold]"
      set -g window-status-separator ""
      set -g window-status-bell-style "fg=#E46876,bg=#1F1F28"

      # ===== Colors (Kanagawa Dragon palette) =====
      set -g status-bg "#1F1F28"
      set -g status-fg "#C8C093"
      set -g message-style "fg=#1F1F28,bg=#98bb6c"
      set -g pane-border-style "fg=#54546D"
      set -g pane-active-border-style "fg=#7e9cd8"

      # ===== Allow passthrough =====
      set -g allow-passthrough on

      # ===== Faster escape time =====
      set -sg escape-time 0

      # ===== Longer display time for messages =====
      set -g display-time 3000

      # ===== Terminal overrides =====
      set -g default-terminal "tmux-256color"
      set -ga terminal-overrides ",xterm-256color:Tc"

      # ===== Resurrect + Continuum (auto-save every 15min) =====
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '15'
      set -g @continuum-boot 'on'
      set -g @resurrect-capture-pane-contents 'on'
    '';
  };
}
