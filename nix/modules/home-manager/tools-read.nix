{ pkgs, ... }:

let
  Pkgs = import ./packages { inherit pkgs; };
in
{
  imports = [
    ./program/gh/
    ./program/git/
    ./program/lazygit/
    ./program/starship/
    ./program/direnv/
    ./program/fzf/
    ./program/bat/
    ./program/tmux/
    ./program/yazi/
    ./program/jujutsu/
    ./program/sops/
    ./program/opencode/
    ./program/claude-code/
    ./program/vscode/
    ./program/docker/
  ];

  home.packages = Pkgs;
}
