# nix/modules/home/programs/fzf/default.nix
#
# widget (CTRL-T / ALT-C / CTRL-R) のオプション指定は home-manager の
# バージョンで形式が異なるため、Intel Mac だけ flat 形式を切り替える。
{ pkgs, ... }:
let
  # Intel Mac だけが home-manager 26.05 スタック (nix/modules/macos/build.nix)。
  # 26.05 には programs.fzf.fileWidget 系が存在せず flat 形式のみ。
  # 26.11 では flat 形式が rename alias として扱われ
  # 「has been renamed to ...」の trace warning が出るため、26.05 だけ flat を使う。
  useFlatWidgetOptions = pkgs.stdenv.hostPlatform.system == "x86_64-darwin";

  fileOpts = [
    "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
    "--preview-window=right:40%,hidden"
    "--bind 'focus:show-preview'"
  ];

  changeDirOpts = [
    "--preview 'eza --tree --color=always {} | head -200'"
    "--preview-window=right:40%,hidden"
    "--bind 'focus:show-preview'"
  ];

  historyOpts = [
    "--sort"
    "--exact"
  ];

  widgets =
    if useFlatWidgetOptions then
      {
        fileWidgetCommand = "fd --type f --hidden --exclude .git";
        changeDirWidgetCommand = "fd --type d --hidden --exclude .git";

        fileWidgetOptions = fileOpts;
        changeDirWidgetOptions = changeDirOpts;
        historyWidgetOptions = historyOpts;
      }
    else
      {
        fileWidget = {
          command = "fd --type f --hidden --exclude .git";
          options = fileOpts;
        };

        changeDirWidget = {
          command = "fd --type d --hidden --exclude .git";
          options = changeDirOpts;
        };

        historyWidget.options = historyOpts;
      };
in
{
  dotfiles.programs.fzf = {
    icon = "🔍";
    note = "widget / shell 統合";
  };

  programs.fzf = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    tmux.enableShellIntegration = true;

    defaultCommand = "fd --type f --hidden --exclude .git";

    defaultOptions = [
      "--height 10"
      "--layout=reverse"
      "--info=inline-right"
      "--prompt '❯ '"
      "--bind 'ctrl-/:change-preview-window(down|hidden|right:40%)'"
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
  }
  // widgets;
}
