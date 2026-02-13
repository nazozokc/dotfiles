{
  description = "nazozo dotfiles (full multi-system with apps)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... }:
  let
    username = "nazozokc";

    pkgsFor = system: import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    ########################################
    # Linux Home Manager
    ########################################
    homeConfigurations.${username} =
      home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor "x86_64-linux";

        # extraSpecialArgs は username だけで十分
        extraSpecialArgs = { inherit username; };

        modules = [
          ./nix/shared.nix
          ./nix/home-manager/common.nix
          ./nix/home-manager/linux.nix
        ];

        home.packages = import ./nix/home-manager/common.nix { pkgs = pkgsFor "x86_64-linux"; };

        home.activation = import ./nix/home-manager/symlinks.nix { pkgs = pkgsFor "x86_64-linux"; inherit username; };
      };

    ########################################
    # macOS nix-darwin
    ########################################
    darwinConfigurations.${username} =
      darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit username; };

        modules = [
          ./nix/os/darwin.nix
        ];

        packages = import ./nix/home-manager/common.nix { pkgs = pkgsFor "aarch64-darwin"; };

        activation = import ./nix/home-manager/symlinks.nix { pkgs = pkgsFor "aarch64-darwin"; inherit username; };
      };

    ########################################
    # apps スクリプト
    ########################################
    apps = {
  "x86_64-linux" = let
    linuxPkgs = pkgsFor "x86_64-linux";
  in {

  switch = {
  type = "app";
  program = builtins.toString (linuxPkgs.writeShellScriptBin "switch" ''
    echo "Building and switching Linux Home Manager config..."
    nix run nixpkgs#home-manager -- switch --flake .#${username}
    echo "Done!"
  '');
};

    
    update-node-packages = {
      type = "app";
      program = builtins.toString (linuxPkgs.writeShellScriptBin "update-node-packages" ''
        echo "Updating Node packages..."
        ${linuxPkgs.bash}/bin/bash ./nix/packages/node/update.sh
        echo "Done!"
      '');
    };
  };

  "aarch64-darwin" = let
    darwinPkgs = pkgsFor "aarch64-darwin";
  in {
    switch = {
      type = "app";
      program = builtins.toString (darwinPkgs.writeShellScriptBin "switch" ''
        echo "Building and switching macOS nix-darwin config..."
        sudo nix run nix-darwin -- switch --flake .#${username}
        echo "Done!"
      '');
    };

    update-node-packages = {
      type = "app";
      program = builtins.toString (darwinPkgs.writeShellScriptBin "update-node-packages" ''
        echo "Updating Node packages on macOS..."
        ${darwinPkgs.bash}/bin/bash ./nix/packages/node/update.sh
        echo "Done!"
      '');
    };
  };
};
  };
}

