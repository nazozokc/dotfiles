final: prev: {
  # TypeScript
  typescript = prev.typescript;
  tsc = prev.typescript;

  # Linting & Formatting
  eslint = prev.eslint;
  prettier = prev.prettier;
  markdownlint-cli = prev.markdownlint-cli;

  # Build tools
  vite = prev.vite;
  webpack = prev.webpack;
  rollup = prev.rollup;

  # Testing
  jest = prev.jest;
  vitest = prev.vitest;

  # CLI utilities
  dotenv-cli = prev.dotenv-cli;

  # Node.js バージョン管理
  nodejs-22 = prev.nodejs_22;
  nodejs-20 = prev.nodejs_20;
}
