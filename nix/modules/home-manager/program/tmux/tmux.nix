{ ... }:
{
  programs.tmux = {
    enable = true;

    clock24 = true;
    mouse = true;
    keyMode = "vi";
    prefix = "C-a";
    terminal = "tmux-256color";
    historyLimit = 100000;

    extraConfig = ''
      # Pane splitting
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # Smart pane switching
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # Copy mode with vi
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

      # Window numbering starts at 1
      set -g base-index 1
      set -g pane-base-index 1

      # Status bar
      set -g status-position bottom
      set -g status-justify left
      set -g status-style "bg=colour235,fg=colour244"
      set -g status-left-length 40
      set -g status-right-length 60

      set -g status-left "#[fg=colour16,bg=colour39,bold] #S #[fg=colour39,bg=colour235,nobold]"
      set -g status-right "#[fg=colour235,bg=colour240,nobold]#[fg=colour244,bg=colour240] %Y-%m-%d  %H:%M #[fg=colour240,bg=colour235,nobold]"

      set -g window-status-format "#[fg=colour240]#[fg=colour244,bg=colour240] #I:#W #[fg=colour240]"
      set -g window-status-current-format "#[fg=colour235,bg=colour39,nobold]#[fg=colour16,bg=colour39,bold] #I:#W #[fg=colour39,bg=colour235,nobold]"
      set -g window-status-separator ""

      # Colors
      set -g status-bg colour235
      set -g status-fg colour244

      # Allow passthrough
      set -g allow-passthrough on

      # Faster escape time
      set -sg escape-time 0

      # Longer display time for messages
      set -g display-time 3000

      # Session options
      set -g default-terminal "tmux-256color"
      set -ga terminal-overrides ",xterm-256color:Tc"
    '';
  };
}
