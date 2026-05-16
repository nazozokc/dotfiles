{ ... }:
{
  programs.starship = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    settings = {
      format = "$all";
      add_newline = true;
      continuation_prompt = "▶▶ ";

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vicmd_symbol = "[❮](bold yellow)";
      };

      directory = {
        truncation_length = 5;
        truncate_to_repo = true;
        fish_style_pwd_dir_length = 1;
      };

      git_branch = {
        format = "[$symbol$branch]($style) ";
        style = "bold purple";
        symbol = " ";
      };

      git_status = {
        format = "([$all_status$ahead_behind]($style)) ";
        style = "bold red";
        conflicted = "=";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        untracked = "?\${count}";
        stashed = "s\${count}";
        modified = "!\${count}";
        staged = "+\${count}";
        renamed = "»\${count}";
        deleted = "✘\${count}";
      };

      nix_shell = {
        format = "[$symbol$state]($style) ";
        symbol = "❄️ ";
        impure_msg = "impure";
        pure_msg = "pure";
        unknown_msg = "??";
        style = "bold blue";
      };

      docker_context = {
        format = "[$symbol$context]($style) ";
        symbol = "🐳 ";
        style = "bold blue";
        detect_files = [
          "docker-compose.yml"
          "docker-compose.yaml"
          "Dockerfile"
        ];
        detect_extensions = [];
      };

      nodejs = {
        format = "[$symbol($version)]($style) ";
        symbol = " ";
        style = "bold green";
      };

      python = {
        format = "[$symbol($version)]($style) ";
        symbol = " ";
        style = "bold yellow";
      };

      rust = {
        format = "[$symbol($version)]($style) ";
        symbol = " ";
        style = "bold red";
      };

      golang = {
        format = "[$symbol($version)]($style) ";
        symbol = " ";
        style = "bold cyan";
      };

      package = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
        style = "bold magenta";
      };

      cmd_duration = {
        format = "[$duration]($style) ";
        style = "bold yellow";
        min_time = 2000;
        show_milliseconds = false;
      };

      time = {
        format = "[$time]($style) ";
        style = "bold blue";
        disabled = true;
      };

      battery.disabled = true;
    };
  };
}
