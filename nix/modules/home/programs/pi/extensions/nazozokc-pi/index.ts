/**
 * nazozokc-pi extension — entry point.
 *
 * Installs a custom header, status panel, footer and editor, plus a toggleable
 * right-hand sidebar, all driven by a single `NazozokcPiController` snapshot. Existing
 * extension statuses (e.g. codex-usage) are preserved by re-rendering them in
 * the custom footer and sidebar.
 *
 * Commands:
 *   /nazozokc-pi [sidebar|panel|help]   Toggle a surface / show help
 *
 * Shortcuts:
 *   alt+h                        Toggle the sidebar
 */

import type {
  ExtensionAPI,
  ExtensionCommandContext,
  ExtensionContext,
  Theme,
} from "@earendil-works/pi-coding-agent";
import type { Component, OverlayHandle, TUI } from "@earendil-works/pi-tui";

import { NazozokcPiController } from "./controller.ts";
import { NazozokcPiEditor } from "./editor.ts";
import { NazozokcPiFooter } from "./footer.ts";
import { NazozokcPiHeader } from "./header.ts";
import { NazozokcPiPanel } from "./panel.ts";
import { NazozokcPiSidebar } from "./sidebar.ts";
import type { NazozokcPiData } from "./types.ts";

const SIDEBAR_KEY = "alt+h";
const SIDEBAR_WIDTH = 48;
const SIDEBAR_MIN_TERMINAL_WIDTH = 110;
const PANEL_KEY = "nazozokc-pi";

export default function nazozokcPiExtension(pi: ExtensionAPI): void {
  const home = process.env.HOME || process.env.USERPROFILE;
  const controller = new NazozokcPiController(pi, home);

  let ctx: ExtensionContext | undefined;
  let fallbackTheme: Theme | undefined;
  let panelEnabled = true;

  const getCtx = (): ExtensionContext | undefined => ctx;
  const getData = (): NazozokcPiData | null =>
    ctx ? controller.getData(ctx) : null;
  const getTheme = (): Theme => ctx?.ui.theme ?? (fallbackTheme as Theme);

  // --- sidebar lifecycle ---------------------------------------------------

  let sidebarClose: ((result: undefined) => void) | null = null;

  function openSidebar(c: ExtensionContext): void {
    if (sidebarClose) return;
    const component: Component = new NazozokcPiSidebar(getData, getTheme, home);
    void c.ui
      .custom<undefined>(
        (_tui: TUI, theme: Theme, _keybindings, done) => {
          fallbackTheme = theme;
          sidebarClose = done;
          return {
            render: (width: number) => component.render(width),
            invalidate: () => component.invalidate?.(),
            dispose: () => {
              sidebarClose = null;
            },
          };
        },
        {
          overlay: true,
          overlayOptions: {
            anchor: "right-center",
            width: SIDEBAR_WIDTH,
            maxHeight: "92%",
            margin: { top: 1, right: 1, bottom: 1 },
            nonCapturing: true,
            visible: (termWidth: number) =>
              termWidth >= SIDEBAR_MIN_TERMINAL_WIDTH,
          },
          onHandle: (_handle: OverlayHandle) => {
            // Handle kept for symmetry; closing goes through the completion
            // callback so the component is disposed.
          },
        },
      )
      .finally(() => {
        sidebarClose = null;
      });
  }

  function closeSidebar(): void {
    const done = sidebarClose;
    sidebarClose = null;
    done?.(undefined);
  }

  function toggleSidebar(c: ExtensionContext): void {
    if (sidebarClose) closeSidebar();
    else openSidebar(c);
  }

  // --- surface installation ------------------------------------------------

  function installPanel(c: ExtensionContext): void {
    if (!panelEnabled) {
      c.ui.setWidget(PANEL_KEY, undefined);
      return;
    }
    c.ui.setWidget(
      PANEL_KEY,
      (tui: TUI, theme: Theme) => {
        controller.attachTui(tui);
        fallbackTheme = theme;
        return new NazozokcPiPanel(getData, getTheme, home);
      },
      { placement: "aboveEditor" },
    );
  }

  function installHeader(c: ExtensionContext): void {
    c.ui.setHeader((tui: TUI, theme: Theme) => {
      controller.attachTui(tui);
      fallbackTheme = theme;
      return new NazozokcPiHeader(getData, getTheme, home);
    });
  }

  function installFooter(c: ExtensionContext): void {
    c.ui.setFooter((tui: TUI, theme: Theme, footerData) => {
      controller.attachTui(tui);
      controller.attachFooterData(footerData);
      fallbackTheme = theme;
      return new NazozokcPiFooter(getCtx, getTheme, footerData, home);
    });
  }

  function installEditor(c: ExtensionContext): void {
    c.ui.setEditorComponent((tui: TUI, theme, keybindings) => {
      controller.attachTui(tui);
      return new NazozokcPiEditor(tui, theme, keybindings, getData, getTheme);
    });
  }

  function installAll(c: ExtensionContext): void {
    // Footer first: it supplies the footer data provider used by the others.
    installFooter(c);
    installHeader(c);
    installPanel(c);
    installEditor(c);
  }

  // --- events --------------------------------------------------------------

  function track(c: ExtensionContext): void {
    ctx = c;
  }

  pi.on("session_start", (_event, c) => {
    if (c.mode !== "tui") return;
    ctx = c;
    controller.reset();
    installAll(c);
    controller.requestRender();
  });

  pi.on("session_shutdown", () => {
    closeSidebar();
    ctx = undefined;
  });

  pi.on("session_info_changed", (_event, c) => {
    track(c);
    controller.requestRender();
  });

  pi.on("agent_start", (_event, c) => {
    track(c);
    controller.requestRender();
  });

  pi.on("agent_end", (_event, c) => {
    track(c);
    controller.requestRender();
  });

  pi.on("turn_end", (_event, c) => {
    track(c);
    controller.requestRender();
  });

  pi.on("message_end", (_event, c) => {
    track(c);
    controller.requestRender();
  });

  pi.on("model_select", (_event, c) => {
    track(c);
    controller.requestRender();
  });

  pi.on("thinking_level_select", (_event, c) => {
    track(c);
    controller.requestRender();
  });

  pi.on("session_compact", (_event, c) => {
    track(c);
    controller.requestRender();
  });

  pi.on("tool_execution_start", (event, c) => {
    track(c);
    controller.onToolStart(event.toolCallId, event.toolName);
  });

  pi.on("tool_execution_end", (event, c) => {
    track(c);
    controller.onToolEnd(event.toolCallId, event.toolName);
  });

  // --- command + shortcut --------------------------------------------------

  pi.registerCommand("nazozokc-pi", {
    description: "Toggle nazozokc-pi surfaces (sidebar, panel)",
    getArgumentCompletions: (prefix) => {
      const options = ["sidebar", "panel", "help"];
      const matches = options.filter((o) => o.startsWith(prefix));
      return matches.length > 0
        ? matches.map((value) => ({ value, label: value }))
        : null;
    },
    handler: async (args: string, c: ExtensionCommandContext) => {
      const sub = args.trim().split(/\s+/)[0] ?? "";
      switch (sub) {
        case "":
        case "sidebar":
          toggleSidebar(c);
          return;
        case "panel":
          panelEnabled = !panelEnabled;
          installPanel(c);
          c.ui.notify(
            panelEnabled ? "nazozokc-pi panel: on" : "nazozokc-pi panel: off",
            "info",
          );
          controller.requestRender();
          return;
        case "help":
        default:
          c.ui.notify(
            "nazozokc-pi — /nazozokc-pi sidebar | /nazozokc-pi panel | alt+h toggles the sidebar",
            "info",
          );
          return;
      }
    },
  });

  pi.registerShortcut(SIDEBAR_KEY, {
    description: "Toggle nazozokc-pi sidebar",
    handler: (c) => {
      if (c.mode !== "tui") return;
      ctx = c;
      toggleSidebar(c);
    },
  });
}
