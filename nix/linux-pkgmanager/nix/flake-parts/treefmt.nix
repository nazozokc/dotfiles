# nix/parts/treefmt.nix
# nix fmt の設定
{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";

        programs = {
          # Nix
          nixfmt = {
            enable = true;
            package = pkgs.nixfmt;
          };

          # テスト用スクリプト (tests/fake-path)
          shfmt = {
            enable = true;
            package = pkgs.shfmt;
          };

          # Nix の警告
          statix = {
            enable = true;
            package = pkgs.statix;
          };

          # 使っていない引数・束縛の検出
          deadnix = {
            enable = true;
            package = pkgs.deadnix;
          };

          # Markdown
          prettier = {
            enable = true;
            package = pkgs.prettier;
            includes = [ "*.md" ];
          };
        };
      };
    };
}
