# home-manager module usage example
{
  imports = [ inputs.linux-pkgmanager.nix.homeManagerModules.default ];
  programs.nlp = {
    enable = true;
    autoDetect = true;
    commonPackages = [ "curl" "git" "jq" ];
    packages = {
      apt = [ "bat" "eza" ];
      pacman = [ "bat" "eza" ];
      dnf = [ "bat" "eza" ];
    };
  };
}
