{
  pkgs,
  lib,
  ...
}:
let
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "nazozokc";
        email = "nazozokc@users.noreply.github.com";
      };

      init.defaultBranch = "main";

      core = {
        editor = "nvim";
        pager = "delta";
        autocorrect = 10;
      };

      pull.rebase = true;
      push = {
        autoSetupRemote = true;
        default = "current";
      };
      fetch.prune = true;
      merge.ff = "only";
      rebase.autoStash = true;
      # credential helper is platform-specific:
      # macOS uses osxkeychain by default, Linux users should configure separately
      commit.gpgSign = false;

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
        fixup = "!f() { git commit --fixup \"$(git rev-parse --abbrev-ref HEAD)\"; }; f";
        squash = "!f() { git rebase -i --autosquash \"${"1:-HEAD~5"}\"; }; f";
        rs = "reset";
        rh = "reset HEAD~1";
        rsh = "reset --hard HEAD~1";
        dc = "diff --cached";
        df = "diff";
        cp = "cherry-pick";
        st = "status -sb";
        cl = "clone --recursive";
        recent = "branch --sort=-committerdate --format='%(committerdate:short) %(refname:short) (%(subject))' | head -20";
        unstage = "restore --staged";
        undo = "reset HEAD~1 --mixed";
      };
    };

    ignores = [
      ".DS_Store"
      "*.swp"
      "*.swo"
      "*~"
      ".direnv"
      "result"
      "result-*"
      ".env"
      ".env.local"
      "node_modules"
      ".venv"
      "__pycache__"
      ".cache"
      ".nix-defexpr"
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
