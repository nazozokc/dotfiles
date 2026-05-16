{ pkgs, config, ... }:

let
  homeDir = config.home.homeDirectory;
  dotfilesDir = "${homeDir}/ghq/github.com/nazozokc/dotfiles";
in
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # Load config from dotfiles directory
      source ${dotfilesDir}/fish/config.fish
    '';

    plugins = [
      {
        name = "autopair-fish";
        inherit (pkgs.fishPlugins.autopair-fish) src;
      }
      {
        name = "bass";
        inherit (pkgs.fishPlugins.bass) src;
      }
      {
        name = "fzf";
        inherit (pkgs.fishPlugins.fzf) src;
      }
      {
        name = "fish-bd";
        inherit (pkgs.fishPlugins.fish-bd) src;
      }
      {
        name = "spark";
        inherit (pkgs.fishPlugins.spark) src;
      }
      {
        name = "fish-abbreviation-tips";
        src = pkgs.fetchFromGitHub {
          owner = "gazorby";
          repo = "fish-abbreviation-tips";
          rev = "8ed76a62bb044ba4ad8e3e6832640178880df485";
          sha256 = "sha256-F1t81VliD+v6WEWqj1c1ehFBXzqLyumx5vV46s/FZRU=";
        };
      }
      {
        name = "nix-env.fish";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
          sha256 = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
        };
      }
      {
        name = "fish-na";
        src = pkgs.fetchFromGitHub {
          owner = "ryoppippi";
          repo = "fish-na";
          rev = "main";
          sha256 = "sha256-wh7HupHGYqo0dPc3bJMPPXuCxJN51dXPOeYkS6nm/Do=";
        };
      }
    ];
  };
}
