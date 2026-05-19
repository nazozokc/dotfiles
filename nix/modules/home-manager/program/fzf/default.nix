{ ... }:
{
  programs.fzf = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    defaultCommand = "fd --type f --hidden --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --exclude .git";

    defaultOptions = [
      "--height 15"
      "--layout=reverse"
      "--border rounded"
      "--margin 1"
      "--preview 'bat --color=always --style=numbers {}'"
      "--preview-window=right:60%,hidden"
      "--bind 'focus:show-preview'"
      "--bind 'ctrl-/:change-preview-window(down|hidden|right:60%)'"
      "--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9"
      "--color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9"
      "--color=info:#8be9fd,prompt:#bd93f9,pointer:#ff79c6"
      "--color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"
    ];

    historyWidgetOptions = [
      "--sort"
      "--exact"
    ];
  };
}
