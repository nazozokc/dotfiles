{ pkgs, ... }:

let
  Pkgs = import ./packages { inherit pkgs; };
in
{
  imports = [
    ./program/gh/gh.nix
    ./program/fish/fish.nix
    ./program/git/git.nix
    ./program/lazygit/lazygit.nix
    ./program/starship/starship.nix
    ./program/direnv/direnv.nix
    ./program/fzf/fzf.nix
    ./program/bat/bat.nix
    ./program/tmux/tmux.nix
    ./program/yazi/yazi.nix
    ./program/jujutsu/jujutsu.nix
    ./program/sops/sops.nix
  ];

  home.packages = Pkgs;
}
