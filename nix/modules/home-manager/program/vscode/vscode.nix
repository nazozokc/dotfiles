{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;

    package = pkgs.vscode;

    extensions = with pkgs.vscode-extensions; [
      # Theme
      tomphilbin.kanagawa
      # AI
      github.copilot
      github.copilot-chat
      # Language support
      jnoortheen.nix-ide
      ms-vscode.vscode-typescript-next
      rust-lang.rust-analyzer
      ms-python.python
      ms-python.vscode-pylance
      ms-vscode.vscode-json
      # Quality of life
      dbaeumer.vscode-eslint
      esbenp.prettier-vscode
      usernamehw.errorlens
      eamodio.gitlens
      # Docker
      ms-azuretools.vscode-docker
      # REST API
      humao.rest-client
      # Neovim integration
      vscodevim.vim
      # Utilities
      streetsidesoftware.code-spell-checker
      gruntfuggly.todo-tree
      formulahendry.auto-rename-tag
      bradlc.vscode-tailwindcss
    ];

    userSettings = {
      # ===== Editor =====
      "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'Noto Sans Mono CJK JP', monospace";
      "editor.fontSize" = 13;
      "editor.lineHeight" = 1.5;
      "editor.tabSize" = 2;
      "editor.detectIndentation" = false;
      "editor.insertSpaces" = true;
      "editor.minimap.enabled" = false;
      "editor.wordWrap" = "on";
      "editor.bracketPairColorization.enabled" = true;
      "editor.guides.bracketPairs" = true;
      "editor.cursorSmoothCaretAnimation" = "on";
      "editor.cursorBlinking" = "smooth";
      "editor.smoothScrolling" = true;
      "editor.formatOnSave" = true;
      "editor.formatOnPaste" = true;
      "editor.codeActionsOnSave" = {
        "source.fixAll.eslint" = "explicit";
        "source.organizeImports" = "explicit";
      };
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "editor.quickSuggestions" = {
        "other" = "on";
        "comments" = "off";
        "strings" = "off";
      };

      # ===== Workbench =====
      "workbench.colorTheme" = "Kanagawa";
      "workbench.iconTheme" = "vscode-icons";
      "workbench.startupEditor" = "none";
      "workbench.statusBar.visible" = true;
      "workbench.activityBar.location" = "default";
      "workbench.sideBar.location" = "left";
      "workbench.editor.showTabs" = "single";
      "workbench.editor.enablePreview" = false;
      "workbench.layoutControl.enabled" = false;

      # ===== Terminal =====
      "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font', 'Noto Sans Mono CJK JP', monospace";
      "terminal.integrated.fontSize" = 13;
      "terminal.integrated.defaultProfile.linux" = "fish";
      "terminal.integrated.defaultProfile.osx" = "fish";
      "terminal.integrated.cursorStyle" = "line";
      "terminal.integrated.smoothScrolling" = true;

      # ===== Files =====
      "files.autoSave" = "afterDelay";
      "files.autoSaveDelay" = 1000;
      "files.exclude" = {
        "**/.git" = false;
        "**/.DS_Store" = true;
        "**/node_modules" = true;
        "**/.direnv" = true;
        "result" = true;
      };
      "files.trimTrailingWhitespace" = true;
      "files.insertFinalNewline" = true;

      # ===== Git =====
      "git.autofetch" = true;
      "git.confirmSync" = false;
      "git.enableSmartCommit" = true;
      "git.openRepositoryInParentFolders" = "always";

      # ===== Explorer =====
      "explorer.compactFolders" = false;
      "explorer.confirmDelete" = false;
      "explorer.confirmDragAndDrop" = false;

      # ===== Telemetry =====
      "telemetry.telemetryLevel" = "off";
      "update.mode" = "none";

      # ===== Vim (vscodevim) =====
      "vim.easymotion" = true;
      "vim.sneak" = true;
      "vim.incsearch" = true;
      "vim.useSystemClipboard" = true;
      "vim.useCtrlKeys" = true;
      "vim.hlsearch" = true;
      "vim.leader" = "<space>";
      "vim.normalModeKeyBindingsNonRecursive" = [
        {
          "before" = [
            "<leader>"
            "f"
          ];
          "commands" = [ "workbench.action.quickOpen" ];
        }
        {
          "before" = [
            "<leader>"
            "b"
          ];
          "commands" = [ "workbench.action.showAllEditors" ];
        }
        {
          "before" = [
            "<leader>"
            "e"
          ];
          "commands" = [ "workbench.action.toggleSidebarVisibility" ];
        }
      ];

      # ===== Language specific =====
      "[typescript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.formatOnSave" = true;
      };
      "[typescriptreact]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.formatOnSave" = true;
      };
      "[javascript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.formatOnSave" = true;
      };
      "[json]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.formatOnSave" = true;
      };
      "[nix]" = {
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
        "editor.formatOnSave" = true;
      };
      "[python]" = {
        "editor.defaultFormatter" = "ms-python.python";
        "editor.formatOnSave" = true;
      };
      "[markdown]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.wordWrap" = "on";
      };

      # ===== Error Lens =====
      "errorLens.enabledDiagnosticLevels" = [
        "error"
        "warning"
      ];
      "errorLens.delayMs" = 300;

      # ===== GitLens =====
      "gitlens.currentLine.enabled" = true;
      "gitlens.hovers.currentLine.over" = "line";
    };
  };
}
