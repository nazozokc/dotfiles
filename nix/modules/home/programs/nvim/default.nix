{
  pkgs,
  config,
  lib,
  dotfilesDir,
  ...
}:
let
  nvimDotfilesDir = "${dotfilesDir}/nvim";

  # lazy.nvim が使う install 先 (実体とバージョンを持つ)
  # ./plugins/default.nix 参照。farm には全プラグインが並んでいる。
  nvimPlugins = import ./plugins { inherit pkgs; };

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

    # プラグインの「実体」は同一ディレクトリの plugins/ が持つ。
    # lazy.nvim は plugin manager としてだけ使い、install 先を
    # LAZY_NIX_PLUGINS (nix store) へ差し替える (init.lua の dev.path)。
    # lazy.nvim 自身も pkgs.vimPlugins.lazy-nvim を使うため、
    # bootstrap の git clone は init.lua で Nix 経路なら行わない。

    withRuby = true;
    withPython3 = true;

    # dotfilesリポジトリのinit.luaを読み込む
    # programs.neovimが生成するinit.luaの末尾に追加されるため、
    # lazy.nvim等のpluginsは既にruntimepathに含まれた状態で実行される
    initLua = builtins.readFile "${nvimDotfilesDir}/init.lua";

    # Set environment variables only for Neovim session
    #
    # `--set NAME VALUE` は nixpkgs の wrapNeovim が `export NAME='VALUE'`
    # に翻訳する。wrapper に入るので、どのシェル / デスクトップアプリから
    # 起動しても同じ値になる (home.sessionVariables だとログインシェルで
    # 開いた terminal だけ wouldn't get it)。
    extraWrapperArgs = [
      # lazy.nvim の install 先 (nix store の farm)
      "--set"
      "LAZY_NIX_PLUGINS"
      "${nvimPlugins.path}"
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

  # lazy.nvim の install 先を nix store へ差し替えるための env 変数は
  # programs.neovim.extraWrapperArgs の `--set LAZY_NIX_PLUGINS` で渡す
  # (nix store の farm = plugins/default.nix)。
  #
  # nvim/lua/plugins/*.lua はそのまま使う (プラグインの宣言は Lua に残す)。
  # init.lua が os.getenv("LAZY_NIX_PLUGINS") を見て lazy.setup の
  # dev.path / dev.fallback を組み立てる。未設定の環境 (Windows 側の
  # apply.ps1 や素の Neovim) では init.lua が従来の clone bootstrap に
  # フォールバックする。

  # lazy-lock.json は「種 (seed)」として Nix 管理の symlink で配置する。
  # lazy.nvim は install/update の最後に必ず lockfile を書き込むが、
  # mkOutOfStoreSymlink は「activation package に複製しない」だけで、
  # 渡したパスが nix store 内 (dotfilesDir = self.outPath) なら終端も
  # read-only のまま = E5113 (Permission denied) で落ちる。
  # `nix run .#switch` を再実行しても symlink は変わらない。
  # よって lockfile の実体は init.lua が stdpath("state") 配下へ作る。
  # ピンをリポジトリへ戻すのは
  #   cp ~/.local/state/nvim/lazy/lazy-lock.json nvim/lazy-lock.json
  # dotfilesリポジトリのnvim/配下を個別にsymlink
  # ディレクトリ全体をsymlinkするとprograms.neovimが生成するinit.luaと衝突するため
  xdg.configFile = {
    "nvim/lua".source = config.lib.file.mkOutOfStoreSymlink "${nvimDotfilesDir}/lua";
    "nvim/lazy-lock.json".source =
      config.lib.file.mkOutOfStoreSymlink "${nvimDotfilesDir}/lazy-lock.json";
    "nvim/template".source = config.lib.file.mkOutOfStoreSymlink "${nvimDotfilesDir}/template";
  };
}
