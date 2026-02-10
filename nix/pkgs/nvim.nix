{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # ===== CLI =====
    git
    curl
    wget
    ripgrep
    fd
    bat
    eza
    fzf
    jq
    tree
    unzip
    zip

    # ===== LSP =====
    lua-language-server        # Lua / Neovim
    nil                        # Nix
    pyright                    # Python
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted # html/css/json/eslint
    bash-language-server
    clang-tools                # clangd (C/C++)
    marksman                   # Markdown
  ];
}

