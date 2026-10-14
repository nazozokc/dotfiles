/**
 * nazozokc-pi extension — entry point.
 *
 * Composition root: builds the controller and shared runtime state, installs
 * the surfaces and on-demand screens on session start, and registers the
 * command and shortcuts. Per-surface logic lives in sibling modules:
 *
 *   state.ts         shared context/theme state
 *   surfaces.ts      header / panel / footer / editor installation
 *   sidebar-host.ts  sidebar overlay lifecycle
 *   screens.ts       help / stats / sessions overlays
 *
 * Commands:
 *   /nazozokc-pi [sidebar|panel|help|stats|sessions]
 *                                Toggle a surface / open a screen
 *
 * Shortcuts:
 *   alt+h                        Toggle the sidebar
 *   alt+i                        Open the help / cheatsheet screen
 *   alt+s                        Open the stats dashboard
 */

import type {
  ExtensionAPI,
  ExtensionCommandContext,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import type { KeyId } from "@earendil-works/pi-tui";

import { NazozokcPiController } from "./controller.ts";
import { NazozokcPiScreens } from "./screens.ts";
import { NazozokcPiSidebarHost } from "./sidebar-host.ts";
import { NazozokcPiState } from "./state.ts";
import { NazozokcPiSurfaces } from "./surfaces.ts";

const SIDEBAR_KEY = "alt+h";
const HELP_KEY = "alt+i";
const STATS_KEY = "alt+s";

export default function nazozokcPiExtension(pi: ExtensionAPI): void {
  const home = process.env.HOME || process.env.USERPROFILE;
  const controller = new NazozokcPiController(pi);
  const state = new NazozokcPiState(controller);
  const surfaces = new NazozokcPiSurfaces(state, controller, home);
  const getTerminalRows = (): number | undefined =>
    controller.getTerminalRows();
  const sidebar = new NazozokcPiSidebarHost({ state, home, getTerminalRows });
  const screens = new NazozokcPiScreens({ pi, state, home, getTerminalRows });

  /** Track the latest context and schedule a repaint (the common event body). */
  const refresh = (ctx: ExtensionContext): void => {
    state.track(ctx);
    controller.requestRender();
  };

  // --- events --------------------------------------------------------------

  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    state.track(ctx);
    controller.reset();
    sidebar.reset();
    surfaces.installAll(ctx);
    controller.requestRender();
  });

  pi.on("session_shutdown", () => {
    sidebar.dispose();
    state.clear();
  });

  pi.on("session_info_changed", (_event, ctx) => refresh(ctx));
  pi.on("agent_start", (_event, ctx) => refresh(ctx));
  pi.on("agent_end", (_event, ctx) => refresh(ctx));
  pi.on("turn_end", (_event, ctx) => refresh(ctx));
  pi.on("message_end", (_event, ctx) => refresh(ctx));
  pi.on("model_select", (_event, ctx) => refresh(ctx));
  pi.on("thinking_level_select", (_event, ctx) => refresh(ctx));
  pi.on("session_compact", (_event, ctx) => refresh(ctx));

  pi.on("tool_execution_start", (event, ctx) => {
    state.track(ctx);
    controller.onToolStart(event.toolCallId, event.toolName);
  });

  pi.on("tool_execution_end", (event, ctx) => {
    state.track(ctx);
    controller.onToolEnd(event.toolCallId, event.toolName);
  });

  // --- command + shortcuts -------------------------------------------------

  pi.registerCommand("nazozokc-pi", {
    description: "nazozokc-pi surfaces (sidebar, panel, help, stats, sessions)",
    getArgumentCompletions: (prefix) => {
      const options = ["sidebar", "panel", "help", "stats", "sessions"];
      const matches = options.filter((o) => o.startsWith(prefix));
      return matches.length > 0
        ? matches.map((value) => ({ value, label: value }))
        : null;
    },
    handler: async (args: string, ctx: ExtensionCommandContext) => {
      const sub = args.trim().split(/\s+/)[0] ?? "";
      switch (sub) {
        case "":
        case "sidebar":
          sidebar.toggle(ctx);
          return;
        case "panel": {
          const enabled = surfaces.togglePanel(ctx);
          ctx.ui.notify(
            enabled ? "nazozokc-pi panel: on" : "nazozokc-pi panel: off",
            "info",
          );
          controller.requestRender();
          return;
        }
        case "help":
          screens.openHelp(ctx);
          return;
        case "stats":
          screens.openStats(ctx);
          return;
        case "sessions":
          await screens.openSessions(ctx);
          return;
        default:
          ctx.ui.notify(
            "nazozokc-pi — sidebar | panel | help | stats | sessions",
            "info",
          );
          return;
      }
    },
  });

  const registerTuiShortcut = (
    key: KeyId,
    description: string,
    open: (ctx: ExtensionContext) => void,
  ): void => {
    pi.registerShortcut(key, {
      description,
      handler: (ctx) => {
        if (ctx.mode !== "tui") return;
        state.track(ctx);
        open(ctx);
      },
    });
  };

  registerTuiShortcut(SIDEBAR_KEY, "Toggle nazozokc-pi sidebar", (ctx) =>
    sidebar.toggle(ctx),
  );
  registerTuiShortcut(HELP_KEY, "Open nazozokc-pi help", (ctx) =>
    screens.openHelp(ctx),
  );
  registerTuiShortcut(STATS_KEY, "Open nazozokc-pi stats", (ctx) =>
    screens.openStats(ctx),
  );
}
