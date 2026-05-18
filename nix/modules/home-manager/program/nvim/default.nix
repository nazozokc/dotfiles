{
  pkgs,
  config,
  dotfilesDir,
  ...
}:
let
  nvimDotfilesDir = "${dotfilesDir}/nvim";

  treesitterGrammars = pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: [
    plugins.nix
    plugins.lua
    plugins.typescript
    plugins.tsx
    plugins.javascript
    plugins.python
    plugins.rust
    plugins.go
    plugins.json
    plugins.yaml
    plugins.toml
    plugins.markdown
    plugins.markdown_inline
    plugins.html
    plugins.css
    plugins.bash
    plugins.dockerfile
    plugins.gitignore
    plugins.regex
    plugins.diff
  ]);
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
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink nvimDotfilesDir;
}
