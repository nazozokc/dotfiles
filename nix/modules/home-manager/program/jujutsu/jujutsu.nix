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
        pager = "delta --dark --paging=never";
      };

      templates = {
        log = ''
          separate(" ",
            commit_timestamp(commit, utc).local().format("%Y-%m-%d %H:%M:%S"),
            if(author.email(), label("email", author.email())),
            if(description.first_line(), label("description", description.first_line())),
            if(empty, label("empty", "(empty)")),
            if(conflict, label("conflict", "(conflict)")),
          )
        '';
      };

      signing = {
        backend = "none";
      };

      git = {
        auto-local-branch = true;
        push-bookmark-prefix = "";
        fetch-bookmark-prefix = "";
      };

      aliases = {
        st = [ "log" "-r" "@+" ];
        br = [ "branch" "list" ];
        co = [ "new" ];
        ci = [ "commit" "-m" ];
        ps = [ "git" "push" ];
        pl = [ "git" "fetch" ];
      };
    };
  };
}
