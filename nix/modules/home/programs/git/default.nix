{
  pkgs,
  lib,
  ...
}:
let
  aliasesFile = ./aliases;
  trash = lib.getExe pkgs.trash-cli;
in
{
  programs.git = {
    enable = true;

    lfs.enable = true;

    signing = {
      format = "ssh";
      signByDefault = true;
      key = null;
    };

    settings = {
      user = {
        name = "nazozokc";
        email = "nazozokc@users.noreply.github.com";
      };

      init.defaultBranch = "main";

      core = {
        editor = "nvim";
        pager = "delta";
        autocrlf = "input";
        ignorecase = false;
        untrackedCache = false;
        fsmonitor = false;
      };

      color.ui = "auto";

      tag.sort = "version:refname";

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

      credential = {
        "https://github.com".helper = [
          ""
          "!gh auth git-credential"
        ];
        "https://gist.github.com".helper = [
          ""
          "!gh auth git-credential"
        ];
      };

      ghq.root = [ "~/ghq" ];

      wt.remover = trash;

      # credential helper is platform-specific:
      # macOS uses osxkeychain by default, Linux users should configure separately
    };

    includes = [
      {
        path = "${aliasesFile}";
      }
    ];

    ignores = [
      # Environment
      ".env"
      ".env.local"
      ".env.*"
      ".direnv"
      ".venv"
      "venv/"
      "env/"
      ".cache"
      ".nix-defexpr"

      # Editor / IDE
      "*.swp"
      "*.swo"
      "*~"
      ".vscode/"
      ".idea/"
      "*.sublime-project"
      "*.sublime-workspace"

      # macOS
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

      # Linux
      "*.out"
      "*.core"

      # Node / JS
      "node_modules/"
      ".npm/"
      ".yarn/"
      "yarn-error.log"
      "yarn.lock"
      "pnpm-lock.yaml"
      "pnpm-store/"

      # Python
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

      # Rust
      "target/"
      "**/*.rs.bk"

      # Nix
      "result"
      "result-*"

      # Image / media
      "*.jpg"
      "*.jpeg"
      "*.png"
      "*.gif"
      "*.ico"
      "*.svg"
      "*.webp"
      "*.mp4"
      "*.mp3"

      # Archives
      "*.zip"
      "*.tar"
      "*.tar.gz"
      "*.tgz"
      "*.tar.xz"
      "*.rar"
      "*.7z"

      # Binaries
      "*.exe"
      "*.dll"
      "*.dylib"
      "*.app"

      # Claude Code
      "**/.claude/settings.local.json"
      "**/.claude/worktrees"
      "**/CLAUDE.local.md"
    ];
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      line-numbers = true;
      side-by-side = true;
      navigate = true;
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
}
