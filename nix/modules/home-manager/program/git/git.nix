{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;

    userName = "nazozokc";
    userEmail = "nazozokc@users.noreply.github.com";

    extraConfig = {
      init.defaultBranch = "main";
      core = {
        editor = "nvim";
        pager = "delta";
      };
      pull.rebase = true;
      push.autoSetupRemote = true;
      fetch.prune = true;
      merge.ff = "only";
      rebase.autoStash = true;
      credential.helper = "store";
      commit.gpgSign = false;
    };

    delta = {
      enable = true;
      options = {
        line-numbers = true;
        side-by-side = true;
        navigate = true;
        features = "decorations";
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

    aliases = {
      s = "status";
      b = "branch";
      c = "commit";
      d = "diff";
      l = "log --oneline --graph --decorate";
      la = "log --oneline --graph --decorate --all";
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
      recent = "branch --sort=-committerdate --format='%(committerdate:short) %(refname:short) (%(subject))' | head -20";
      unstage = "restore --staged";
      undo = "reset HEAD~1 --mixed";
    };
  };
}
