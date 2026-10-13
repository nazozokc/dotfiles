/**
 * nazozokc-pi extension — entry point.
 *
 * Installs a custom header, status panel, footer and editor, plus a right-hand
 * sidebar, all driven by a single `NazozokcPiController` snapshot. Existing
 * extension statuses (e.g. codex-usage) are preserved by re-rendering them in
 * the custom footer and sidebar.
 *
 * The sidebar is a non-capturing overlay anchored to the top-right. It stays
 * hidden by default and is opened on demand with `alt+h` or
 * `/nazozokc-pi sidebar`.
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
  Theme,
} from "@earendil-works/pi-coding-agent";
import { SessionManager } from "@earendil-works/pi-coding-agent";
import type {
  Component,
  KeyId,
  OverlayHandle,
  TUI,
} from "@earendil-works/pi-tui";

import { NazozokcPiController } from "./controller.ts";
import { NazozokcPiEditor } from "./editor.ts";
import { NazozokcPiFooter } from "./footer.ts";
import { NazozokcPiHeader } from "./header.ts";
import { NazozokcPiHelp } from "./help.ts";
import { NazozokcPiPanel } from "./panel.ts";
import { NazozokcPiSessions } from "./sessions.ts";
import { NazozokcPiSidebar } from "./sidebar.ts";
import { NazozokcPiStats } from "./stats.ts";
import type { NazozokcPiData } from "./types.ts";

const SIDEBAR_KEY = "alt+h";
const HELP_KEY = "alt+i";
const STATS_KEY = "alt+s";
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

  let sidebarHandle: OverlayHandle | null = null;
  let sidebarClose: ((result: undefined) => void) | null = null;
  let sidebarVisible = false;

  /**
   * Drop tracking for the overlay. `resetExtensionUI()` (session switch/fork/
   * new, `/reload`) pops the overlay from the stack, so the handle and close
   * callback must not be trusted across a session boundary.
   */
  function resetSidebarState(): void {
    sidebarHandle = null;
    sidebarClose = null;
    sidebarVisible = false;
  }

  /** Register the overlay once per session and make sure it is shown. */
  function openSidebar(c: ExtensionContext): void {
    sidebarVisible = true;
    if (sidebarClose) {
      sidebarHandle?.setHidden(false);
      return;
    }
    const component: Component = new NazozokcPiSidebar(
      getData,
      getTheme,
      home,
      () => controller.getTerminalRows(),
    );
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
              sidebarHandle = null;
            },
          };
        },
        {
          overlay: true,
          overlayOptions: {
            anchor: "top-right",
            width: SIDEBAR_WIDTH,
            maxHeight: "96%",
            margin: { top: 0, right: 1, bottom: 1 },
            nonCapturing: true,
            visible: (termWidth: number) =>
              termWidth >= SIDEBAR_MIN_TERMINAL_WIDTH,
          },
          onHandle: (handle: OverlayHandle) => {
            sidebarHandle = handle;
            // The handle resolves asynchronously; honor an early toggle-off.
            if (!sidebarVisible) handle.setHidden(true);
          },
        },
      )
      .finally(() => {
        sidebarClose = null;
        sidebarHandle = null;
      });
  }

  /** Toggle by hiding the overlay, so the stack order stays untouched. */
  function setSidebarVisible(visible: boolean): void {
    sidebarVisible = visible;
    sidebarHandle?.setHidden(!visible);
  }

  function toggleSidebar(c: ExtensionContext): void {
    if (!sidebarClose) openSidebar(c);
    else setSidebarVisible(!sidebarVisible);
  }

  // --- on-demand screens ---------------------------------------------------

  /** Capturable centered overlay options shared by help/stats/sessions. */
  const screenOptions = {
    overlay: true,
    overlayOptions: {
      anchor: "center" as const,
      width: "80%" as const,
      maxHeight: "85%" as const,
      margin: 1,
    },
  };

  function openHelp(c: ExtensionContext): void {
    const commands = pi
      .getCommands()
      .map((cmd) => ({ name: cmd.name, description: cmd.description }));
    void c.ui.custom<undefined>(
      (_tui, theme, _keybindings, done) =>
        new NazozokcPiHelp(
          getData,
          getTheme,
          home,
          commands,
          done,
          () => controller.getTerminalRows(),
        ),
      screenOptions,
    );
  }

  function openStats(c: ExtensionContext): void {
    void c.ui.custom<undefined>(
      (_tui, theme, _keybindings, done) =>
        new NazozokcPiStats(getData, getTheme, done, () =>
          controller.getTerminalRows(),
        ),
      screenOptions,
    );
  }

  async function openSessions(c: ExtensionCommandContext): Promise<void> {
    const sessions = await SessionManager.listAll();
    sessions.sort((a, b) => b.modified.getTime() - a.modified.getTime());
    const current = c.sessionManager.getSessionFile();
    const chosen = await c.ui.custom<string | undefined>(
      (_tui, theme, _keybindings, done) =>
        new NazozokcPiSessions(
          theme,
          done,
          sessions,
          current,
          home,
          () => controller.getTerminalRows(),
        ),
      screenOptions,
    );
    if (chosen && chosen !== current) await c.switchSession(chosen);
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
    resetSidebarState();
    installAll(c);
    controller.requestRender();
  });

  pi.on("session_shutdown", () => {
    const done = sidebarClose;
    resetSidebarState();
    done?.(undefined);
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
    description: "nazozokc-pi surfaces (sidebar, panel, help, stats, sessions)",
    getArgumentCompletions: (prefix) => {
      const options = ["sidebar", "panel", "help", "stats", "sessions"];
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
          openHelp(c);
          return;
        case "stats":
          openStats(c);
          return;
        case "sessions":
          await openSessions(c);
          return;
        default:
          c.ui.notify(
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
    open: (c: ExtensionContext) => void,
  ): void => {
    pi.registerShortcut(key, {
      description,
      handler: (c) => {
        if (c.mode !== "tui") return;
        ctx = c;
        open(c);
      },
    });
  };

  registerTuiShortcut(SIDEBAR_KEY, "Toggle nazozokc-pi sidebar", toggleSidebar);
  registerTuiShortcut(HELP_KEY, "Open nazozokc-pi help", openHelp);
  registerTuiShortcut(STATS_KEY, "Open nazozokc-pi stats", openStats);
}
