{ inputs, username, ... }:

{
  ########################################
  # nix-darwin entry
  ########################################
  imports = [
    ../darwin/system.nix
  ];

  ########################################
  # Home Manager を macOS に統合
  ########################################
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${username} = import ../home-manager/common.nix;
  };
}

