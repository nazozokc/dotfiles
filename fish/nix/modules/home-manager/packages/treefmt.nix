# nix/modules/treefmt.nix
# treefmt-nix によるフォーマッター統合設定
# 使い方: nix fmt
{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
        # nix fmt で全ファイルを一括フォーマット
        projectRootFile = "flake.nix";

        programs = {
          # Nix
          nixfmt = {
            enable = true;
            package = pkgs.nixfmt-rfc-style;
          };

          # Lua (Neovim設定)
          stylua.enable = true;

          # Shell
          shfmt = {
            enable = true;
            indent_size = 2;
          };

          # Markdown / JSON / YAML / TypeScript
          prettier = {
            enable = true;
            includes = [
              "*.md"
              "*.json"
              "*.yaml"
              "*.yml"
              "*.ts"
              "*.js"
            ];
            excludes = [
              "nvim/template/*"
            ];
          };
        };

        # fish は fish_indent を直接呼ぶ（treefmt 未対応のため）
        settings.formatter.fish = {
          command = "${pkgs.fish}/bin/fish_indent";
          options = [ "--write" ];
          includes = [ "*.fish" ];
        };
      };
    };
}
