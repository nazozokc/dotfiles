{
  pkgs,
  lib,
  config,
  ...
}:

let
  checkJsonschema = lib.getExe pkgs.check-jsonschema;
  delta = lib.getExe pkgs.delta;

  gitLogFormat = ''git log --pretty=format:"%Cgreen%h %Creset%cd %Cblue[%cn] %Creset%s%C(yellow)%d%C(reset)" --graph --date=relative --decorate'';

  schemaUrl = "https://raw.githubusercontent.com/jesseduffield/lazygit/master/schema/config.json";
  lazygitConfigFile = "${config.xdg.configHome}/lazygit/config.yml";
in
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
        skipRewordInEditorWarning = true;
        disableStartupPopups = true;

        # Kanagawa theme
        theme = {
          activeBorderColor = [
            "#7FB4CA"
            "bold"
          ];
          inactiveBorderColor = [ "#727169" ];
          searchingActiveBorderColor = [
            "#E6C384"
            "bold"
          ];
          optionsTextColor = [ "#8DAA9A" ];
          selectedLineBgColor = [ "#2D2D3D" ];
          inactiveViewSelectedLineBgColor = [ "default" ];
          cherryPickedCommitFgColor = [ "#7FB4CA" ];
          cherryPickedCommitBgColor = [ "#363646" ];
          markedBaseCommitFgColor = [ "#E6C384" ];
          markedBaseCommitBgColor = [ "#363646" ];
          unstagedChangesColor = [ "#E46876" ];
          defaultFgColor = [ "#DCD7BA" ];
        };
      };

      git = {
        pagers = [
          {
            pager = "${delta} --dark --paging=never";
            colorArg = "always";
          }
        ];

        commit = {
          signOff = false;
          autoWrapCommitMessage = true;
          autoWrapWidth = 72;
        };

        merging = {
          args = "";
          squashMergeMessage = "Squash merge {{selectedRef}} into {{currentBranch}}";
        };

        mainBranches = [
          "master"
          "main"
          "develop"
        ];
        skipHookPrefix = "WIP";
        autoFetch = true;
        autoRefresh = true;
        autoForwardBranches = "onlyMainBranches";
        autoStageResolvedConflicts = true;
        fetchAll = true;
        overrideGpg = true;
        ignoreWhitespaceInDiffView = false;
        diffContextSize = 3;
        renameSimilarityThreshold = 50;
        branchPrefix = "";

        log = {
          order = "topo-order";
          showGraph = "always";
        };

        branchLogCmd = "${gitLogFormat} {{branchName}} --";
        allBranchesLogCmds = [ "${gitLogFormat} --all" ];

        localBranchSortOrder = "date";
        remoteBranchSortOrder = "date";
        truncateCopiedCommitHashesTo = 12;
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
      confirmOnQuit = false;
      quitOnTopLevelReturn = false;
      disableStartupPopups = true;
    };
  };

  home.activation.validateLazygitSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    SETTINGS_FILE="${lazygitConfigFile}"

    echo "Validating lazygit config.yml..."
    if ${checkJsonschema} --default-filetype yaml --schemafile "${schemaUrl}" "$SETTINGS_FILE" 2>&1; then
      echo "lazygit config.yml validation passed"
    else
      echo "warning: lazygit config.yml validation failed (schema may be outdated)" >&2
    fi
  '';
}
