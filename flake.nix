{
  description = "nazozo dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, zen-browser, ... }:
  let
    username = "nazozokc";

    mkHome = system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit zen-browser;
        };

        modules = [
          {
            home.username = username;

            home.homeDirectory =
              if pkgs.stdenv.isDarwin
              then "/Users/${username}"
              else "/home/${username}";

            home.stateVersion = "24.05";

            programs.home-manager.enable = true;

            imports = [
              ./nix/config-sym.nix
              ./nix/pkgs/cli/cli-tool.nix
              ./nix/pkgs/nvim.nix
              ./nix/pkgs/gui/gui-tool.nix
            ];
          }
        ];
      };
  in
  {
    homeConfigurations = {
      # 今使ってるLinux
      ${username} = mkHome "x86_64-linux";

      # 将来Macに行ったら追加するだけ
      # ${username}-mac = mkHome "aarch64-darwin";
    };
  };
}

