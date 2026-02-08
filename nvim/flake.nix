packages = with pkgs; [
  nodejs_20
  nodePackages.typescript
  nodePackages.typescript-language-server
  nodePackages.eslint
  lua-language-server
  html-languageserver
  solargraph
];
