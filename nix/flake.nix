{
  description = "nazozokc personal packages (apps + neovim LSP)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = { allowUnfree = true; };
    };

    appsEnv = pkgs.buildEnv {
      name = "nazozokc-apps";
      paths = import ./apps/packages.nix { inherit pkgs; };
    };

    lspEnv = pkgs.buildEnv {
      name = "nazozokc-lsp";
      paths = import ./nvim/lsp.nix { inherit pkgs; };
    };
  in
  {
    packages.${system} = {
      apps = appsEnv;
      lsp  = lspEnv;

      default = pkgs.buildEnv {
        name = "nazozokc-default";
        paths = [
          appsEnv
          lspEnv
        ];
        ignoreCollisions = true;  # npm などの man ページ衝突を無視
      };
    };
  };
}

