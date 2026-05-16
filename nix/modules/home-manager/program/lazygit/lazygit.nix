{ ... }:
{
  programs.lazygit = {
    enable = true;

    settings = {
      gui = {
        language = "en";
        showFileTree = true;
        showRandomTip = false;
        showCommandLog = false;
        showBottomLine = true;
        nerdFontsVersion = "3";
        theme = {
          activeBorderColor = [
            "green"
            "bold"
          ];
          inactiveBorderColor = [
            "default"
          ];
          selectedLineBgColor = [
            "default"
          ];
        };
      };

      git = {
        paging = {
          colorArg = "always";
          pager = "delta --dark --paging=never";
        };
        commit = {
          signOff = false;
          autoWrapCommitMessage = true;
          autoWrapWidth = 72;
        };
      };

      os = {
        editCommand = "nvim";
        editCommandTemplate = "{{editor}} +{{line}} {{filename}}";
      };

      customCommands = [
        {
          key = "C";
          command = "git commit";
          context = "files";
          description = "commit";
        }
        {
          key = "<c-r>";
          command = "gh pr create";
          context = "localBranches";
          description = "create pull request";
        }
        {
          key = "D";
          command = "git push --delete origin {{.SelectedLocalBranch.Name}}";
          context = "localBranches";
          description = "delete remote branch";
          loadingText = "Deleting remote branch...";
        }
        {
          key = "T";
          command = "gh browse --branch {{.SelectedLocalBranch.Name}}";
          context = "localBranches";
          description = "open in browser";
        }
      ];

      notARepository = "skip";
    };
  };
}
