# nix/modules/home-manager/packages/treefmt.nix
# treefmt-nix によるフォーマッター統合設定
# 使い方: nix fmt
{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    { pkgs, system, ... }:
    {
      treefmt = {
        # nix fmt で全ファイルを一括フォーマット
        projectRootFile = "flake.nix";

        programs = {
          # Nix
          nixfmt = {
            enable = true;
            package = pkgs.nixfmt;
          };

          # Lua (Neovim設定)
          # nvim/template 配下は sonictemplate のテンプレートで、
          # {{_expr_:expand('%:t:r')}} 等のプレースホルダを含むため整形できない。
          stylua = {
            enable = true;
            excludes = [ "nvim/template/*" ];
          };

          # Shell
          shfmt = {
            enable = true;
            indent_size = 2;
          };

          # Markdown / JSON / YAML / TypeScript
          prettier = {
            enable = true;
            # prettier は nixpkgs バージョンで出力が変わる (3.8.3 と 3.9.10 では
            # `_` のエスケープとコードブロック後の空行が食い違う)。
            # x86_64-darwin は unstable から削除済みで Intel スタック (26.05) を
            # 使うため、全プラットフォームで 26.05 の prettier に固定して
            # フォーマット結果を揃える (差異は nix fmt -- --ci が毎回落とすため)。
            package = inputs.nixpkgs-intel.legacyPackages.${system}.prettier;
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
              "fish/nvim/template/*"
              "**/lazy-lock.json"
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
