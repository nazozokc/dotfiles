# nix/flake-parts/dev-shells.nix
# 開発用の shellHook。`nix develop` / `nix develop .#nix` / `nix develop .#editors`
{
  perSystem =
    { pkgs, ... }:
    {
      devShells = {
        default = pkgs.mkShell {
          name = "dotfiles-default";
          packages = with pkgs; [
            git
            just
          ];
          shellHook = ''
            echo "[devShell:default]"
            git --version
            just --version
          '';
        };

        nix = pkgs.mkShell {
          name = "dotfiles-nix";
          packages = with pkgs; [
            nixfmt
            statix
            deadnix
            nil
            nixd
          ];
          shellHook = ''
            echo "[devShell:nix]"
            nix --version
            nixfmt --version
            statix --version
            deadnix --version
          '';
        };

        editors = pkgs.mkShell {
          name = "dotfiles-editors";
          packages = with pkgs; [
            stylua
            nodejs_24
          ];
          shellHook = ''
            echo "[devShell:editors]"
            stylua --version
            node --version
          '';
        };
      };
    };
}
