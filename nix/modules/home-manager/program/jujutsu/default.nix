{ pkgs, ... }:
{
  programs.jujutsu = {
    enable = true;

    settings = {
      user = {
        name = "nazozokc";
        email = "nazozokc@users.noreply.github.com";
      };

      ui = {
        default-command = "log";
        color = "auto";
        editor = "nvim";
        paginate = "auto";
        diff-formatter = ":color-words";
        graph.style = "square";
        log-word-wrap = true;
        show-cryptographic-signatures = false;

        movement = {
          edit = true;
        };

        pager = "delta --dark --paging=never";

        streampager = {
          interface = "quit-if-one-page";
          show-ruler = true;
          wrapping = "word";
        };
      };

      diff.color-words = {
        max-inline-alternation = 3;
        context = 3;
      };

      templates = {
        log = "builtin_log_compact";
        show = "builtin_log_detailed";
        evolog = "builtin_evolog_compact";
        draft_commit_description = ''
          concat(
            builtin_draft_commit_description,
            "\nJJ: ignore-rest\n",
            diff.git(),
          )
        '';
      };

      template-aliases = {
        "format_short_id(id)" = "id.shortest(12)";
        "format_short_signature(signature)" = "signature";
        "format_timestamp(timestamp)" = "timestamp.ago()";
      };

      revsets = {
        log = "present(@) | ancestors(immutable_heads().., 2) | trunk()";
        short-prefixes = "(main..@)::";
        bookmark-advance-from = "heads(::to & bookmarks())";
        bookmark-advance-to = "@";
      };

      revset-aliases = {
        "immutable_heads()" = "builtin_immutable_heads()";
      };

      signing = {
        backend = "none";
      };

      git = {
        auto-local-branch = true;
        push-bookmark-prefix = "";
        fetch-bookmark-prefix = "";
        abandon-unreachable-commits = true;
      };

      snapshot = {
        auto-update-stale = true;
      };

      aliases = {
        st = [
          "log"
          "-r"
          "@+"
        ];
        br = [
          "branch"
          "list"
        ];
        co = [ "new" ];
        ci = [
          "commit"
          "-m"
        ];
        ps = [
          "git"
          "push"
        ];
        pl = [
          "git"
          "fetch"
        ];
        d = [ "diff" ];
        evo = [ "evolog" ];
        fix = [
          "squash"
          "-r"
          "@-"
        ];
        amend = [ "squash" ];
        abandon = [ "abandon" ];
        track = [
          "bookmark"
          "track"
        ];
        untrack = [
          "bookmark"
          "untrack"
        ];
      };
    };
  };
}
