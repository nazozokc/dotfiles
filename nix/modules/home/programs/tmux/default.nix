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
      tmuxPlugins.tmux-fzf
      tmuxPlugins.fuzzback
      tmuxPlugins.tmux-thumbs
      tmuxPlugins.tmux-floax
      tmuxPlugins.ukiyo
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
      bind Tab select-pane -t :.+
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

      # ===== Ukiyo theme (Kanagawa Dragon) =====
      set -g @ukiyo-theme "kanagawa/dragon"
      set -g @ukiyo-refresh-rate 30
      set -g @ukiyo-show-git true
      set -g @ukiyo-show-prefix true
      set -g @ukiyo-show-cwd true
      set -g @ukiyo-pane-run-true-colors true
      set -g @ukiyo-plugins "cpu-usage ram-usage battery network weather time"

      # ===== tmux-floax (floating popup) =====
      set -g @floax-bind Escape
      set -g @floax-width 80%
      set -g @floax-height 80%

      # ===== tmux-thumbs (hint text selection) =====
      set -g @thumbs-key "t"
      set -g @thumbs-alphabet "numeric"
      set -g @thumbs-unique "on"

      # ===== Colors (Kanagawa Dragon palette - fallback) =====
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
