{
  pkgs,
  config,
  lib,
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
    plugins.c
    plugins.cpp
    plugins.sql
  ]);
in
{
  programs.neovim = {
    enable = true;

    # lazy.nvim is managed by itself via bootstrap in init.lua.
    # Nixで提供するとdoc/tagsが読み取り専用(nix store)になり、
    # helptags生成でE152が発生するため。

    withRuby = true;
    withPython3 = true;

    # dotfilesリポジトリのinit.luaを読み込む
    # programs.neovimが生成するinit.luaの末尾に追加されるため、
    # lazy.nvim等のpluginsは既にruntimepathに含まれた状態で実行される
    initLua = builtins.readFile "${nvimDotfilesDir}/init.lua";

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
      # TypeScript / JavaScript: TS7 (Go ネイティブ実装) 内蔵の LSP。
      # nvim-lspconfig の tsgo 設定が PATH 上の `tsgo` を探す。
      tsgo
      sqls
      clang-tools

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

      # Process discovery (opencode.nvim needs lsof)
      lsof
    ];
  };

  # NOTE: lazy-lock.json も Nix store (read-only) になるため、そのままでは
  # lazy.nvim が install/update 時に lockfile を書き込めない (E5113)。
  # init.lua 側で state's lockfile にコピーして運用する。

  # dotfilesリポジトリのnvim/配下を個別にsymlink
  # ディレクトリ全体をsymlinkするとprograms.neovimが生成するinit.luaと衝突するため
  xdg.configFile = {
    "nvim/lua".source = config.lib.file.mkOutOfStoreSymlink "${nvimDotfilesDir}/lua";
    "nvim/lazy-lock.json".source =
      config.lib.file.mkOutOfStoreSymlink "${nvimDotfilesDir}/lazy-lock.json";
    "nvim/template".source = config.lib.file.mkOutOfStoreSymlink "${nvimDotfilesDir}/template";
  };
}
