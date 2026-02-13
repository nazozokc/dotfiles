{
  description = "nazozo dotfiles (multi-system, apps fixed)";

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

  outputs = { self, nixpkgs, home-manager, darwin, ... }@inputs:
  let
    username = "nazozokc";

    pkgsFor = system: import nixpkgs { inherit system; config.allowUnfree = true; };
    linuxPkgs   = pkgsFor "x86_64-linux";
    darwinPkgs  = pkgsFor "aarch64-darwin";

    homeDir = system: if builtins.match ".*-darwin" system != null
                      then "/Users/${username}"
                      else "/home/${username}";

    dotfilesDir = system: "${homeDir system}/ghq/github.com/nazozokc/dotfiles";
  in
  {
    ########################################
    # Linux Home Manager
    ########################################
    homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
      pkgs = linuxPkgs;
      extraSpecialArgs = { inherit username; };
      modules = [
        ./nix/shared.nix
        ./nix/home-manager/common.nix
        ./nix/home-manager/linux.nix
      ];

      home.packages = import ./nix/home-manager/common.nix { pkgs = linuxPkgs; };
      home.activation = import ./nix/home-manager/symlinks.nix { pkgs = linuxPkgs; inherit username; };
    };

    ########################################
    # macOS nix-darwin
    ########################################
    darwinConfigurations.${username} = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit username; };
      modules = [
        ./nix/os/darwin.nix
      ];

      packages = import ./nix/home-manager/common.nix { pkgs = darwinPkgs; };
      activation = import ./nix/home-manager/symlinks.nix { pkgs = darwinPkgs; inherit username; };
    };

    ########################################
    # Apps / スクリプト (writeShellScriptBin + type="app")
    ########################################
    apps = {
      "x86_64-linux" = {
        switch = {
          type = "app";
          program = linuxPkgs.writeShellScriptBin "hm-switch" ''
            set -e
            echo "Building and switching Linux Home Manager config..."
            nix run nixpkgs#home-manager -- switch --flake .#${username}
            echo "Done!"
          '';
        };

        update = {
          type = "app";
          program = linuxPkgs.writeShellScriptBin "flake-update" ''
            set -e
            echo "Updating flake.lock..."
            nix flake update
            echo "Done!"
          '';
        };

        update-node-packages = {
          type = "app";
          program = linuxPkgs.writeShellScriptBin "node-update" ''
            set -e
            echo "Updating Node.js packages..."
            ${linuxPkgs.bash}/bin/bash ${dotfilesDir "x86_64-linux"}/nix/packages/node/update.sh
            echo "Done!"
          '';
        };
      };

      "aarch64-darwin" = {
        switch = {
          type = "app";
          program = darwinPkgs.writeShellScriptBin "darwin-switch" ''
            set -e
            echo "Building and switching macOS nix-darwin config..."
            sudo nix run nix-darwin -- switch --flake .#${username}
            echo "Done!"
          '';
        };

        update = {
          type = "app";
          program = darwinPkgs.writeShellScriptBin "flake-update" ''
            set -e
            echo "Updating flake.lock..."
            nix flake update
            echo "Done!"
          '';
        };

        update-node-packages = {
          type = "app";
          program = darwinPkgs.writeShellScriptBin "node-update" ''
            set -e
            echo "Updating Node.js packages..."
            ${darwinPkgs.bash}/bin/bash ${dotfilesDir "aarch64-darwin"}/nix/packages/node/update.sh
            echo "Done!"
          '';
        };
      };
    };
  };
}
{
  description = "nazozo dotfiles (multi-system, apps fixed)";

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

  outputs = { self, nixpkgs, home-manager, darwin, ... }@inputs:
  let
    username = "nazozokc";

    pkgsFor = system: import nixpkgs { inherit system; config.allowUnfree = true; };
    linuxPkgs   = pkgsFor "x86_64-linux";
    darwinPkgs  = pkgsFor "aarch64-darwin";

    homeDir = system: if builtins.match ".*-darwin" system != null
                      then "/Users/${username}"
                      else "/home/${username}";

    dotfilesDir = system: "${homeDir system}/ghq/github.com/nazozokc/dotfiles";
  in
  {
    ########################################
    # Linux Home Manager
    ########################################
    homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
      pkgs = linuxPkgs;
      extraSpecialArgs = { inherit username; };
      modules = [
        ./nix/shared.nix
        ./nix/home-manager/common.nix
        ./nix/home-manager/linux.nix
      ];

      home.packages = import ./nix/home-manager/common.nix { pkgs = linuxPkgs; };
      home.activation = import ./nix/home-manager/symlinks.nix { pkgs = linuxPkgs; inherit username; };
    };

    ########################################
    # macOS nix-darwin
    ########################################
    darwinConfigurations.${username} = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit username; };
      modules = [
        ./nix/os/darwin.nix
      ];

      packages = import ./nix/home-manager/common.nix { pkgs = darwinPkgs; };
      activation = import ./nix/home-manager/symlinks.nix { pkgs = darwinPkgs; inherit username; };
    };

    ########################################
    # Apps / スクリプト (writeShellScriptBin + type="app")
    ########################################
    apps = {
      "x86_64-linux" = {
        switch = {
          type = "app";
          program = linuxPkgs.writeShellScriptBin "hm-switch" ''
            set -e
            echo "Building and switching Linux Home Manager config..."
            nix run nixpkgs#home-manager -- switch --flake .#${username}
            echo "Done!"
          '';
        };

        update = {
          type = "app";
          program = linuxPkgs.writeShellScriptBin "flake-update" ''
            set -e
            echo "Updating flake.lock..."
            nix flake update
            echo "Done!"
          '';
        };

        update-node-packages = {
          type = "app";
          program = linuxPkgs.writeShellScriptBin "node-update" ''
            set -e
            echo "Updating Node.js packages..."
            ${linuxPkgs.bash}/bin/bash ${dotfilesDir "x86_64-linux"}/nix/packages/node/update.sh
            echo "Done!"
          '';
        };
      };

      "aarch64-darwin" = {
        switch = {
          type = "app";
          program = darwinPkgs.writeShellScriptBin "darwin-switch" ''
            set -e
            echo "Building and switching macOS nix-darwin config..."
            sudo nix run nix-darwin -- switch --flake .#${username}
            echo "Done!"
          '';
        };

        update = {
          type = "app";
          program = darwinPkgs.writeShellScriptBin "flake-update" ''
            set -e
            echo "Updating flake.lock..."
            nix flake update
            echo "Done!"
          '';
        };

        update-node-packages = {
          type = "app";
          program = darwinPkgs.writeShellScriptBin "node-update" ''
            set -e
            echo "Updating Node.js packages..."
            ${darwinPkgs.bash}/bin/bash ${dotfilesDir "aarch64-darwin"}/nix/packages/node/update.sh
            echo "Done!"
          '';
        };
      };
    };
  };
}

