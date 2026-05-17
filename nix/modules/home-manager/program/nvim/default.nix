{
  pkgs,
  config,
  ...
}:
let
  dotfilesDir = "${config.home.homeDirectory}/ghq/github.com/nazozokc/dotfiles";
  nvimDotfilesDir = "${dotfilesDir}/nvim";

  treesitterGrammars = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
in
{
  programs.neovim = {
    enable = true;

    withRuby = true;
    withPython3 = true;

    # Set environment variables only for Neovim session
    extraWrapperArgs = [
      "--set"
      "TREESITTER_GRAMMARS"
      "${treesitterGrammars}"
    ];

    # These packages are only available when NeoVim is running
    extraPackages = with pkgs; [
      # Plugin build dependencies (lazy.nvim build steps)
      cmake
      gcc

      # Language servers
      lua-language-server
      nixd
      efm-langserver
      pyright
      typos-lsp
      typescript-language-server

      # Python tools
      ruff

      # Formatters & Linters (used by efm-langserver)
      stylua
      hadolint
      actionlint

      # Node.js-based language servers
      astro-language-server
      emmet-language-server
      prisma-language-server
      stylelint
      stylelint-lsp
      svelte-language-server
      tailwindcss-language-server
      textlint
      vscode-langservers-extracted
      vue-language-server
      yaml-language-server
    ];
  };

  # dotfilesリポジトリのnvim/を~/.config/nvimにsymlink
  home.activation.linkNvim = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    dotfilesDir="${nvimDotfilesDir}"
    target="$HOME/.config/nvim"

    if [ -L "$target" ]; then
      # 既存のsymlinkを貼り直し
      rm -f "$target"
      ln -s "$dotfilesDir" "$target"
    elif [ -e "$target" ]; then
      # 実ファイル/ディレクトリがある場合は退避
      backup="$target.bak.$(date +%Y%m%d%H%M%S)"
      echo "WARNING: $target exists. Moving to $backup"
      mv "$target" "$backup"
      ln -s "$dotfilesDir" "$target"
    else
      ln -s "$dotfilesDir" "$target"
    fi
  '';
}
