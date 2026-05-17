{ pkgs, ... }:

let
  Pkgs = import ./packages/wsl.nix { inherit pkgs; };
in
{
  imports = [
    ./program/gh
    ./program/git
    ./program/lazygit
    ./program/starship
    ./program/direnv.nix
    ./program/fzf
    ./program/bat
    ./program/tmux
    ./program/yazi
    ./program/jujutsu
    ./program/sops
    ./program/opencode
    ./program/claude-code
    ./program/ghostty.nix
    ./program/docker
  ];

  home.packages = Pkgs;
}
