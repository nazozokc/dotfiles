{ config, pkgs, ... }:

{
  programs.gh-dash = {
    enable = true;

    settings = {
      # Kanagawa Dragon color scheme
      theme = {
        colors = {
          text = {
            primary = "#c5c9c5"; # fg0 - main text for titles, headers
            secondary = "#c8c9c1"; # fg1 - secondary text, PR numbers
            inverted = "#181616"; # bg0 - inverted text on bright bg
            faint = "#6f7a6e"; # fg3 - muted text, time, help
            warning = "#c4746e"; # red - changes requested, CI fail
            success = "#87a987"; # green - approved, CI pass
            actor = "#c4b28a"; # yellow - notification trigger user
          };

          background = {
            selected = "#2c2a2a"; # bg4 - selected row, active tab
          };

          border = {
            primary = "#8ba4b0"; # blue - section dividers, search box
            secondary = "#898b87"; # gray - tab separators
            faint = "#211f1f"; # bg2 - row separators
          };
        };

        ui = {
          sectionsShowCount = true;
          table = {
            showSeparator = true;
            compact = false;
          };
        };
      };

      prSections = [
        {
          title = "My Pull Requests";
          filters = "is:open author:@me";
        }
        {
          title = "Needs My Review";
          filters = "is:open review-requested:@me";
        }
        {
          title = "Involved";
          filters = "is:open involves:@me -author:@me";
        }
      ];

      issuesSections = [
        {
          title = "My Issues";
          filters = "is:open author:@me";
        }
        {
          title = "Assigned";
          filters = "is:open assignee:@me";
        }
        {
          title = "Involved";
          filters = "is:open involves:@me -author:@me";
        }
      ];

      notificationsSections = [
        {
          title = "All";
          filters = "";
        }
        {
          title = "Created";
          filters = "reason:author";
        }
        {
          title = "Participating";
          filters = "reason:participating";
        }
        {
          title = "Mentioned";
          filters = "reason:mention";
        }
        {
          title = "Review Requested";
          filters = "reason:review-requested";
        }
        {
          title = "Assigned";
          filters = "reason:assign";
        }
        {
          title = "Subscribed";
          filters = "reason:subscribed";
        }
        {
          title = "Team Mentioned";
          filters = "reason:team-mention";
        }
      ];

      defaults = {
        view = "prs";
        refetchIntervalMinutes = 30;
        prsLimit = 20;
        prApproveComment = "LGTM";
        issuesLimit = 20;
        notificationsLimit = 20;
        preview = {
          open = true;
          width = 0.45;
          height = 0.60;
          position = "auto";
        };
        dateFormat = "relative";
        layout = {
          prs = {
            updatedAt = {
              width = 5;
            };
            createdAt = {
              width = 5;
            };
            repo = {
              width = 20;
            };
            author = {
              width = 15;
            };
            authorIcon = {
              hidden = false;
            };
            labels = {
              width = 22;
              hidden = true;
            };
            assignees = {
              width = 20;
              hidden = true;
            };
            base = {
              width = 15;
              hidden = true;
            };
            lines = {
              width = 15;
            };
          };
          issues = {
            updatedAt = {
              width = 5;
            };
            createdAt = {
              width = 5;
            };
            repo = {
              width = 15;
            };
            creator = {
              width = 10;
            };
            creatorIcon = {
              hidden = false;
            };
            assignees = {
              width = 20;
              hidden = true;
            };
          };
        };
      };

      repo = {
        branchesRefetchIntervalSeconds = 30;
        prsRefetchIntervalSeconds = 60;
      };

      confirmQuit = false;
      showAuthorIcons = true;
      smartFilteringAtLaunch = true;
      includeReadNotifications = true;

      pager = {
        diff = "";
      };

      keybindings = { };
      repoPaths = { };
    };
  };
}
