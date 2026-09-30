{
  pkgs,
  lib,
  ...
}:
let
  trash = lib.getExe pkgs.trash-cli;
in
{
  programs.git = {
    enable = true;

    lfs.enable = true;

    # Platform-specific signing (SSH key path differs per platform).
    # Kept OFF: signing needs an SSH key under ~/.ssh and this machine has
    # none (only known_hosts). With signByDefault on, home-manager emits
    # tag.gpgsign = true, which nothing here overrides, so every `git tag`
    # dies with:
    #   fatal: either user.signingkey or gpg.ssh.defaultKeyCommand needs to be configured
    # To turn signing on: create a key, point `key` at it per platform here,
    # and drop `commit.gpgSign = false` from settings below.
    signing = {
      format = "ssh";
      signByDefault = false;
      key = null;
    };

    # Every setting lives here. `settings` is home-manager's generic INI
    # generator (attrset -> `[section] key = value`), so ~/.config/git/config
    # is rendered by Nix instead of being symlinked in from the repo.
    #
    # It must stay a single attrset, not a list of fragments: home-manager's
    # gh module also writes `programs.git.settings`, and `either gitIniType
    # (listOf gitIniType)` can only merge when every definition has the same
    # shape. Repeated keys are expressed as a list value instead, which
    # toGitINI renders as duplicated keys.
    settings = {

      user = {
        name = "nazozokc";
        email = "nazozokc@users.noreply.github.com";
      };

      init.defaultBranch = "main";

      protocol.version = 2;

      transfer.fsckObjects = true;

      core = {
        editor = "nvim";
        pager = "delta";
        autocrlf = "input";
        ignorecase = false;
        untrackedCache = false;
        fsmonitor = false;
        symlinks = true;
        # Rendered by `ignores` below, same path home-manager has always used.
        excludesFile = "~/.config/git/ignore";
      };

      color.ui = "auto";

      tag.sort = "version:refname";

      log.date = "iso-strict";

      status = {
        short = true;
        submoduleSummary = true;
        aheadBehind = false;
      };

      maintenance = {
        auto = true;
        strategy = "incremental";
      };

      interactive.singleKey = true;

      blame = {
        date = "iso-strict";
        coloring = "repeatedLines";
      };

      pull.rebase = true;

      push = {
        default = "current";
        autoSetupRemote = true;
        useForceIfIncludes = true;
      };

      fetch = {
        prune = true;
        pruneTags = true;
        writeCommitGraph = true;
        showForcedUpdates = false;
        all = true;
      };

      merge = {
        ff = "only";
        conflictstyle = "zdiff3";
      };

      rebase = {
        autoStash = true;
        autoSquash = true;
        updateRefs = true;
      };

      commit = {
        verbose = true;
        gpgSign = false;
      };

      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        mnemonicPrefix = true;
        renames = true;
      };

      help.autocorrect = 10;

      column.ui = "auto";

      branch.sort = "-committerdate";

      rerere = {
        enabled = true;
        autoupdate = true;
      };

      remote.pushDefault = "origin";

      ghq.root = "~/ghq";

      # wt.remover uses the nix-store path to trash-cli.
      # Do NOT move this into `programs.delta.options`: that only reaches
      # git config when `enableGitIntegration` is on, and it would be
      # rendered from `iniContent`, which is emitted *before* `settings`.
      wt.remover = trash;

      alias = {
        s = "status";
        b = "branch";
        c = "commit";
        d = "diff";
        l = "log --oneline --graph --decorate";
        ll = "log --oneline --graph --decorate --all";
        la = "log --all --graph --decorate --format='%C(auto)%h%C(reset) %C(blue)%an%C(reset) %C(green)%ar%C(reset) %s'";
        p = "push";
        pl = "pull";
        co = "checkout";
        cb = "checkout -b";
        a = "add";
        aa = "add --all";
        cm = "commit -m";
        ca = "commit --amend";
        can = "commit --amend --no-edit";
        rs = "reset";
        rh = "reset HEAD~1";
        rsh = "reset --hard HEAD~1";
        dc = "diff --cached";
        df = "diff";
        cp = "cherry-pick";
        st = "status -sb";
        cl = "clone --recursive";
        unstage = "restore --staged";
        undo = "reset HEAD~1 --mixed";
        fixup = "!f() { git commit --fixup \"$(git rev-parse --abbrev-ref HEAD)\"; }; f";
        squash = "!f() { git rebase -i --autosquash \"\${1:-HEAD~5}\"; }; f";
        recent = "!f() { git branch --sort=-committerdate --format='%(committerdate:short) %(refname:short) (%(subject))' | head -\${1:-20}; }; f";
        whoami = "log --format='%an <%ae>' -1";
        contributors = "shortlog -sn HEAD";
        root = "rev-parse --show-toplevel";
        worktree = "!f() { git worktree add \"$(git rev-parse --show-toplevel)/../$1\" -b \"$1\"; }; f";
        # Web / browsing
        browse = "!gh repo view --web";
        browse-pr = "!gh pr view --web";
        # No surrounding quotes: git strips a leading `!"..."` down to
        # `!echo ...` when it parses the file, so quoting the value here
        # would put literal quotes into the shell command.
        brc = "!echo $(gh repo view --json url --jq .url)/commit/$(git rev-parse HEAD)";
        # Branch management
        main = "!f() { local b; b=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null); git switch \"\${b#origin/}\" 2>/dev/null || git switch main; }; f";
        dlr = "!sh -c 'git branch -D \"$1\" && git push origin :\"$1\"' -";
        clean-branches = "!git branch --merged | grep -v '\\*\\|main\\|master\\|develop' | xargs -r git branch -d";
        swf = "!git branch -a | fzf | xargs git switch";
        # History / log
        logg = "log --graph --abbrev-commit --pretty=format:\"%C(yellow)%h%C(reset) - %C(cyan)%ad%C(reset) %C(green)(%ar)%C(reset)%C(auto)%d%C(reset)%n          %C(white)%s%C(reset)%n\" --date=iso-strict";
        rb = "!git reflog --pretty='%gs' | grep 'checkout:' | awk '{print $NF}' | awk '!seen[$0]++' | head -20";
        today = "!git log --since=midnight --author=$(git config user.name) --oneline --shortstat";
        # Interactive staging
        apf = "!git ls-files -m -o --exclude-standard | fzf -m --print0 --preview 'git diff {} | delta' | xargs -0 -o -t git add -p";
        # Utility
        aliases = "!git config --get-regexp alias | sed 's/^alias.//' | sort";
      };

      # credential helper: uses gh auth. The empty entry clears any helper
      # inherited from system config, the second installs gh's.
      credential."https://github.com".helper = [
        ""
        "!gh auth git-credential"
      ];
      credential."https://gist.github.com".helper = [
        ""
        "!gh auth git-credential"
      ];

      # delta pager configuration
      delta = {
        line-numbers = true;
        side-by-side = true;
        navigate = true;
        diff-so-fancy = true;
        keep-plus-minus-markers = true;
        features = "decorations";
        syntax-theme = "Monokai Extended";
        true-color = "always";
        hyperlinks = true;
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-decoration-style = "none";
          file-style = "bold yellow";
          hunk-header-decoration-style = "cyan box";
          hunk-header-file-style = "yellow";
          hunk-header-line-number-style = "cyan";
          hunk-header-style = "file line-number syntax";
        };
      };
    };

    # Rendered to ~/.config/git/ignore (see core.excludesFile above). Comment
    # and blank lines are kept as list entries so the file stays grouped.
    ignores = [
      "# Environment"
      ".env"
      ".env.local"
      ".env.*"
      ".direnv"
      ".venv"
      "venv/"
      "env/"
      ".cache"
      ".nix-defexpr"
      ""
      "# Editor / IDE"
      "*.swp"
      "*.swo"
      "*~"
      ".vscode/"
      ".idea/"
      "*.sublime-project"
      "*.sublime-workspace"
      ""
      "# macOS"
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      "Icon"
      "._*"
      ".DocumentRevisions-V100"
      ".fseventsd"
      ".Spotlight-V100"
      ".TemporaryItems"
      ".Trashes"
      ".VolumeIcon.icns"
      ""
      "# Linux"
      "*.out"
      "*.core"
      ""
      "# Node / JS"
      "node_modules/"
      ".npm/"
      ".yarn/"
      "yarn-error.log"
      "pnpm-store/"
      ""
      "# Python"
      "__pycache__/"
      "*.py[cod]"
      "*$py.class"
      "*.so"
      ".Python"
      "build/"
      "develop-eggs/"
      "dist/"
      "downloads/"
      "eggs/"
      ".eggs/"
      "lib64/"
      "parts/"
      "sdist/"
      "var/"
      "wheels/"
      "*.egg-info/"
      ".installed.cfg"
      "*.egg"
      "*.manifest"
      "*.spec"
      "pip-log.txt"
      "pip-delete-this-directory.txt"
      "htmlcov/"
      ".tox/"
      ".nox/"
      ".coverage"
      ".mypy_cache/"
      ".pytest_cache/"
      ".ruff_cache/"
      ".hypothesis/"
      "*.mo"
      "*.pot"
      "*.log"
      "local_settings.py"
      "db.sqlite3"
      ".python-version"
      ""
      "# Rust"
      "target/"
      "**/*.rs.bk"
      ""
      "# Nix"
      "result"
      "result-*"
      ""
      "# Image / media"
      "*.jpg"
      "*.jpeg"
      "*.png"
      "*.gif"
      "*.ico"
      "*.svg"
      "*.webp"
      "*.mp4"
      "*.mp3"
      ""
      "# Archives"
      "*.zip"
      "*.tar"
      "*.tar.gz"
      "*.tgz"
      "*.tar.xz"
      "*.rar"
      "*.7z"
      ""
      "# Binaries"
      "*.exe"
      "*.dll"
      "*.dylib"
      "*.app"
      ""
      "# Claude Code"
      "**/.claude/settings.local.json"
      "**/.claude/worktrees"
      "**/CLAUDE.local.md"
      ""
      "# Bun"
      ".bun-cache/"
      ""
      "# Editor"
      ".cursor/"
    ];
  };

  programs.delta = {
    enable = true;
    # Delta's own config lives in `programs.git.settings` above, so
    # enableGitIntegration stays off: turning it on would rewrite core.pager
    # and add pager.blame / interactive.diffFilter that this config never had.
  };
}
