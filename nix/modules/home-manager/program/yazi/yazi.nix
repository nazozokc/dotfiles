{ ... }:
{
  programs.yazi = {
    enable = true;

    shellWrapperName = "y";

    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    settings = {
      manager = {
        show_hidden = true;
        sort_by = "natural";
        sort_sensitive = true;
        sort_dir_first = true;
        linemode = "size";
        ratio = [
          1
          3
          4
        ];
      };

      preview = {
        tab_size = 2;
        max_width = 600;
        max_height = 900;
        cache_dir = "";
      };

      opener = {
        edit = [
          {
            run = "nvim \"$@\"";
            desc = "Edit with neovim";
            block = true;
          }
        ];
      };

      open = {
        rules = [
          { name = "*/"; use = "edit"; }
        ];
      };
    };

    keymap = {
      manager.prepend_keymap = [
        {
          on = [ "g" "c" ];
          run = "cd ~/.config";
          desc = "Go to config directory";
        }
        {
          on = [ "g" "d" ];
          run = "cd ~/Downloads";
          desc = "Go to downloads directory";
        }
        {
          on = [ "g" "p" ];
          run = "cd ~/ghq/github.com/nazozokc";
          desc = "Go to projects directory";
        }
        {
          on = [ "<C-s>" ];
          run = "shell \"$SHELL\" --block";
          desc = "Open shell in current directory";
        }
      ];
    };

    theme = {
      manager = {
        border_symbol = "│";
        show_symlink = true;
      };
    };
  };
}
