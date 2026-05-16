{ pkgs, ... }:

let
  Pkgs = import ./packages/wsl.nix { inherit pkgs; };
in
{
  imports = [
    ./program/gh/gh.nix
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
    ./program/opencode/opencode.nix
    ./program/claude-code/claude-code.nix
  ];

  home.packages = Pkgs;
}
