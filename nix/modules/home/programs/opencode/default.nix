{
  config,
  pkgs,
  dotfilesDir,
  ...
}:

let
  link = config.lib.file.mkOutOfStoreSymlink;
  mcpConfig = import ../../../../overlays/mcp/mcp.nix { inherit config pkgs; };
  permConfig = import ../../../../overlays/mcp/permissions.nix { };
in
{
  dotfiles.programs.opencode = {
    icon = "🧠";
    note = "agent / LSP / MCP";
  };

  xdg.configFile = {
    "opencode/opencode.json".text = builtins.toJSON {
      "\$schema" = "https://opencode.ai/config.json";

      shell = "${pkgs.fish}/bin/fish";

      default_agent = "build";

      permission = permConfig.opencode;

      # mode を省略すると primary 扱いになり、built-in の subagent (explore/general)
      # を上書きしたり「subagent のつもりが primary」になったりする。全定義で明示する。
      agent = {
        build = {
          mode = "primary";
          description = "Default coding agent: implements features, fixes bugs, writes code";
          steps = 20;
          prompt = "You are a build agent. Focus on implementing features, fixing bugs, and writing code. Follow existing patterns and conventions.";
        };
        dangerously-skip-permission = {
          mode = "primary";
          description = "Unattended build agent with all tool calls auto-approved";
          prompt = ''
            You are running in dangerously-skip-permission mode. All tool calls — including bash commands, file edits, subagent invocations, and user questions — execute without confirmation prompts.

            This mode is intended for trusted, automated workflows and rapid iteration. You still must:
            - Verify the intent of destructive operations (rm, git push --force, database drops, system-level writes) before issuing them.
            - Respect .env file protection — secrets must never be read, logged, or written.
            - Refuse to exfiltrate data, install untrusted packages, or modify files outside the project scope without explicit user intent.
            - Stop and surface a clear summary if a tool result indicates data loss, permission escalation, or an unexpected environment.

            When in doubt about a side effect, choose the safer action and explain it in your reply rather than silently proceeding.
          '';
          permission = {
            bash = "allow";
            task = "allow";
            question = "allow";
          };
        };
        plan = {
          mode = "primary";
          description = "Architecture, design, and detailed implementation plans";
          temperature = 0.3;
          steps = 10;
          prompt = "You are a planning agent. Focus on architecture, design, and creating detailed implementation plans. Think before acting.";
        };
        review = {
          mode = "subagent";
          description = "Review current changes for correctness, security, and maintainability";
          temperature = 0.2;
          steps = 12;
          prompt = "You are a code review agent. Review the current changes for correctness, security, and maintainability. Report concrete findings with file:line references and severity. Do not modify files.";
          permission = {
            edit = "deny";
            task = {
              "*" = "deny";
            };
          };
        };
        test = {
          mode = "subagent";
          description = "Write or update focused tests and run the relevant test commands";
          temperature = 0.2;
          steps = 15;
          prompt = "You are a test agent. Write or update focused tests for the current changes, run the relevant test commands, and report failures and coverage gaps.";
          permission = {
            task = {
              "*" = "deny";
            };
          };
        };
        explore = {
          mode = "subagent";
          description = "Read-only codebase exploration: patterns, structure, context";
          steps = 15;
          prompt = "You are an exploration agent. Focus on understanding the codebase, finding patterns, and gathering context.";
          permission = {
            edit = "deny";
            task = {
              "*" = "deny";
            };
          };
        };
        scout = {
          mode = "subagent";
          description = "Quick read-only information gathering and codebase questions";
          steps = 10;
          prompt = "You are a scout agent. Focus on quick information gathering and answering questions about the codebase.";
          permission = {
            edit = "deny";
            task = {
              "*" = "deny";
            };
          };
        };
        # built-in の hidden 保守エージェント。visible primary にしない。
        title = {
          mode = "primary";
          hidden = true;
          steps = 1;
        };
        summary = {
          mode = "primary";
          hidden = true;
          steps = 1;
        };
        compaction = {
          mode = "primary";
          hidden = true;
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
          # TypeScript 7 (Go ネイティブ実装) 内蔵の LSP。
          # tsserver を廃した typescript-language-server に代わる。
          command = [
            "${pkgs.tsgo}/bin/tsgo"
            "--lsp"
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

      mcp = mcpConfig.opencode;

      # These paths are glob patterns resolved by opencode at runtime, not by Nix
      instructions = [
        "${dotfilesDir}/opencode/rules/*.md"
        "${dotfilesDir}/opencode/output-style/*.md"
      ];

      skills = {
        paths = [
          "${dotfilesDir}/agents/skills"
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
