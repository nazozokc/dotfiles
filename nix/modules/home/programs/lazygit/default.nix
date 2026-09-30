{
  pkgs,
  lib,
  config,
  ...
}:

let
  checkJsonschema = lib.getExe pkgs.check-jsonschema;

  # Pin the schema to the version of lazygit that is actually installed.
  # master drifts, so an unpinned URL makes this check non-reproducible and
  # turns it into a coin flip on every switch.
  schemaUrl = "https://raw.githubusercontent.com/jesseduffield/lazygit/v${pkgs.lazygit.version}/schema/config.json";
  lazygitConfigFile = "${config.xdg.configHome}/lazygit/config.yml";
in
{
  programs.lazygit = {
    enable = true;

    # Rendered to ~/.config/lazygit/config.yml by home-manager's YAML
    # generator. The activation below validates it against lazygit's own
    # schema, so a typo in here fails at switch time instead of at runtime.
    settings = {
      gui = {
        language = "en";
        showFileTree = true;
        showRandomTip = false;
        showCommandLog = false;
        showBottomLine = true;
        nerdFontsVersion = "3";
        skipRewordInEditorWarning = true;
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
        diffRenderers = [
          {
            command = "delta --dark --paging=never";
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
        branchLogCmd = "git log --pretty=format:\"%Cgreen%h %Creset%cd %Cblue[%cn] %Creset%s%C(yellow)%d%C(reset)\" --graph --date=relative --decorate {{branchName}} --";
        allBranchesLogCmds = [
          "git log --pretty=format:\"%Cgreen%h %Creset%cd %Cblue[%cn] %Creset%s%C(yellow)%d%C(reset)\" --graph --date=relative --decorate --all"
        ];
        localBranchSortOrder = "date";
        remoteBranchSortOrder = "date";
        truncateCopiedCommitHashesTo = 12;
      };

      os.editPreset = "nvim";

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

  home.activation.validateLazygitSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    SETTINGS_FILE="${lazygitConfigFile}"

    echo "Validating lazygit config.yml against v${pkgs.lazygit.version} schema..."
    # NOTE: do not append `2>&1` here. Inside the `if` condition it swallows
    # check-jsonschema's diagnostics, so an invalid config only ever printed a
    # generic warning and nobody could see which keys were wrong.
    if ${checkJsonschema} --default-filetype yaml --schemafile "${schemaUrl}" "$SETTINGS_FILE"; then
      echo "lazygit config.yml validation passed"
    else
      echo "warning: lazygit config.yml validation failed against v${pkgs.lazygit.version} schema (see errors above)" >&2
    fi
  '';
}
