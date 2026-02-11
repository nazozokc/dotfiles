{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # ===== LSP =====
    lua-language-server        # Lua / Neovim
    nil                        # Nix
    pyright                    # Python
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted # html/css/json/eslint
    bash-language-server
    clang-tools                # clangd (C/C++)
    marksman                   # Markdown
    nil
  ];
}

