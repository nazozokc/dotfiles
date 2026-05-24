{ ... }:
{
  programs.fzf = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    tmux.enableShellIntegration = true;

    defaultCommand = "fd --type f --hidden --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --exclude .git";

    defaultOptions = [
      "--height 10"
      "--layout=reverse"
      "--info=inline-right"
      "--prompt '❯ '"
      "--bind 'ctrl-/:change-preview-window(down|hidden|right:40%)'"
    ];

    fileWidgetOptions = [
      "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
      "--preview-window=right:40%,hidden"
      "--bind 'focus:show-preview'"
    ];

    changeDirWidgetOptions = [
      "--preview 'eza --tree --color=always {} | head -200'"
      "--preview-window=right:40%,hidden"
      "--bind 'focus:show-preview'"
    ];

    historyWidgetOptions = [
      "--sort"
      "--exact"
    ];

    colors = {
      fg = "#f8f8f2";
      bg = "#282a36";
      hl = "#bd93f9";
      "fg+" = "#f8f8f2";
      "bg+" = "#44475a";
      "hl+" = "#bd93f9";
      info = "#8be9fd";
      prompt = "#bd93f9";
      pointer = "#ff79c6";
      marker = "#ff79c6";
      spinner = "#ffb86c";
      header = "#6272a4";
    };
  };
}
