{ pkgs, ... }:
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # Enable vi mode
      fish_vi_key_bindings

      # Abbreviations
      abbr -a g git
      abbr -a gc 'git commit'
      abbr -a ga 'git add'
      abbr -a gp 'git push'
      abbr -a gs 'git status'
      abbr -a gl 'git log --oneline --graph --decorate'
      abbr -a d docker
      abbr -a dc 'docker compose'
      abbr -a n nix
      abbr -a nb 'nix build'
      abbr -a ns 'nix shell'
      abbr -a nf 'nix flake'
      abbr -a hm home-manager
      abbr -a c clear
      abbr -a ll 'eza -la --icons'
      abbr -a ls 'eza --icons'
      abbr -a lt 'eza -T --icons'
      abbr -a cat bat
      abbr -a ps 'btop'
      abbr -a lg lazygit
      abbr -a y yazi
      abbr -a z zoxide
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
    ];

    functions = {
      nixgc = ''
        nix-collect-garbage -d
      '';
      nixupdate = ''
        nix flake update
      '';
      mkcd = ''
        mkdir -p $argv[1]; and cd $argv[1]
      '';
    };
  };
}
