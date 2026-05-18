{
  config,
  pkgs,
  dotfilesDir,
  ...
}:

let
  homeDir = config.home.homeDirectory;
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  xdg.configFile = {
    "opencode/opencode.json".text = builtins.toJSON {
      "\$schema" = "https://opencode.ai/config.json";

      shell = "${pkgs.fish}/bin/fish";

      default_agent = "build";

      permission = {
        read = "allow";
        edit = "allow";
        glob = "allow";
        grep = "allow";
        list = "allow";
        bash = "ask";
        task = "ask";
        webfetch = "allow";
        websearch = "allow";
        skill = "allow";
        todowrite = "allow";
        question = "ask";
        lsp = "allow";
      };

      agent = {
        build = {
          steps = 20;
          prompt = "You are a build agent. Focus on implementing features, fixing bugs, and writing code. Follow existing patterns and conventions.";
        };
        plan = {
          temperature = 0.3;
          steps = 10;
          prompt = "You are a planning agent. Focus on architecture, design, and creating detailed implementation plans. Think before acting.";
        };
        explore = {
          steps = 15;
          prompt = "You are an exploration agent. Focus on understanding the codebase, finding patterns, and gathering context.";
        };
        scout = {
          steps = 10;
          prompt = "You are a scout agent. Focus on quick information gathering and answering questions about the codebase.";
        };
        title = {
          steps = 1;
        };
        summary = {
          steps = 1;
        };
        compaction = {
          steps = 1;
        };
      };

      lsp = {
        nix = {
          command = [ "${pkgs.nixd}/bin/nixd" ];
          extensions = [ "nix" ];
        };
        lua = {
          command = [ "${pkgs.lua-language-server}/bin/lua-language-server" ];
          extensions = [ "lua" ];
        };
        typescript = {
          command = [
            "${pkgs.typescript-language-server}/bin/typescript-language-server"
            "--stdio"
          ];
          extensions = [
            "ts"
            "tsx"
            "js"
            "jsx"
            "mjs"
            "cjs"
          ];
        };
        rust = {
          command = [ "${pkgs.rust-analyzer}/bin/rust-analyzer" ];
          extensions = [ "rs" ];
        };
        go = {
          command = [ "${pkgs.gopls}/bin/gopls" ];
          extensions = [ "go" ];
        };
        c = {
          command = [ "${pkgs.clang-tools}/bin/clangd" ];
          extensions = [
            "c"
            "h"
          ];
        };
      };

      formatter = {
        nix = {
          command = [ "${pkgs.nixfmt}/bin/nixfmt" ];
          extensions = [ "nix" ];
        };
        lua = {
          command = [
            "${pkgs.stylua}/bin/stylua"
            "-"
          ];
          extensions = [ "lua" ];
        };
        typescript = {
          command = [
            "${pkgs.prettier}/bin/prettier"
            "--stdin-filepath"
          ];
          extensions = [
            "ts"
            "tsx"
            "js"
            "jsx"
            "mjs"
            "cjs"
            "css"
            "json"
            "md"
            "yaml"
            "yml"
          ];
        };
        rust = {
          command = [ "${pkgs.rustfmt}/bin/rustfmt" ];
          extensions = [ "rs" ];
        };
      };

      mcp =
        let
          linuxMcp = {
            playwright = {
              type = "local";
              command = [
                "${pkgs.playwright-mcp}/bin/playwright-mcp"
                "--browser"
                "chromium"
                "--no-sandbox"
              ];
              env = {
                PWMCP_PROFILES_DIR_FOR_TEST = "${homeDir}/.local/share/playwright-mcp/profiles";
              };
              enabled = true;
            };
          };
        in
        {
          context7 = {
            type = "local";
            command = [
              "${pkgs.bun}/bin/bunx"
              "-y"
              "@upstash/context7-mcp"
            ];
            enabled = true;
          };
        }
        // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux linuxMcp;

      # These paths are glob patterns resolved by opencode at runtime, not by Nix
      instructions = [
        "${dotfilesDir}/opencode/rules/*.md"
        "${dotfilesDir}/opencode/output-style/*.md"
      ];

      skills = {
        paths = [
          "${dotfilesDir}/opencode/skills"
        ];
      };

      reference = {
        dotfiles = {
          repository = "github:nazozokc/dotfiles";
        };
      };

      compaction = {
        auto = true;
        prune = true;
        tail_turns = 2;
        reserved = 4096;
      };

      tool_output = {
        max_lines = 2000;
        max_bytes = 51200;
      };

      watcher = {
        ignore = [
          ".git/**"
          "result/**"
          "result-*"
          ".direnv/**"
          ".venv/**"
          "__pycache__/**"
          "*.pyc"
          ".cache/**"
        ];
      };

      autoupdate = "notify";

      snapshot = true;

      attachment = {
        image = {
          auto_resize = true;
          max_width = 2000;
          max_height = 2000;
          max_base64_bytes = 5242880;
        };
      };
    };

    "opencode/tui.json".text = builtins.toJSON {
      "\$schema" = "https://opencode.ai/tui.json";
      theme = "kanagawa";
    };

    "opencode/rules".source = link "${dotfilesDir}/opencode/rules";
    "opencode/output-style".source = link "${dotfilesDir}/opencode/output-style";
    "opencode/AGENTS.md".source = link "${dotfilesDir}/opencode/AGENTS.md";
  };
}
