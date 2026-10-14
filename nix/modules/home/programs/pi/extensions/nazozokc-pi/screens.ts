/**
 * nazozokc-pi extension — on-demand screens.
 *
 * Opens the centered overlays: help/cheatsheet, stats dashboard and the session
 * switcher. Each screen is a capturable overlay (the sidebar is the only
 * non-capturing one) and shares the same overlay options.
 */

import type {
  ExtensionAPI,
  ExtensionCommandContext,
  ExtensionContext,
  Theme,
} from "@earendil-works/pi-coding-agent";
import { SessionManager } from "@earendil-works/pi-coding-agent";
import type { TUI } from "@earendil-works/pi-tui";

import { NazozokcPiHelp } from "./help.ts";
import { NazozokcPiSessions } from "./sessions.ts";
import { NazozokcPiStats } from "./stats.ts";
import type { NazozokcPiState } from "./state.ts";

/** Capturable centered overlay options shared by help/stats/sessions. */
const SCREEN_OPTIONS = {
  overlay: true,
  overlayOptions: {
    anchor: "center" as const,
    width: "80%" as const,
    maxHeight: "85%" as const,
    margin: 1,
  },
};

export interface NazozokcPiScreenDeps {
  pi: ExtensionAPI;
  state: NazozokcPiState;
  home: string | undefined;
  getTerminalRows: () => number | undefined;
}

export class NazozokcPiScreens {
  constructor(private readonly deps: NazozokcPiScreenDeps) {}

  openHelp(ctx: ExtensionContext): void {
    const { pi, state, home, getTerminalRows } = this.deps;
    const commands = pi
      .getCommands()
      .map((cmd) => ({ name: cmd.name, description: cmd.description }));
    void ctx.ui.custom<undefined>(
      (_tui: TUI, _theme: Theme, _keybindings, done) =>
        new NazozokcPiHelp(
          state.getData,
          state.getTheme,
          home,
          commands,
          done,
          getTerminalRows,
        ),
      SCREEN_OPTIONS,
    );
  }

  openStats(ctx: ExtensionContext): void {
    const { state, getTerminalRows } = this.deps;
    void ctx.ui.custom<undefined>(
      (_tui: TUI, _theme: Theme, _keybindings, done) =>
        new NazozokcPiStats(
          state.getData,
          state.getTheme,
          done,
          getTerminalRows,
        ),
      SCREEN_OPTIONS,
    );
  }

  async openSessions(ctx: ExtensionCommandContext): Promise<void> {
    const sessions = await SessionManager.listAll();
    sessions.sort((a, b) => b.modified.getTime() - a.modified.getTime());
    const current = ctx.sessionManager.getSessionFile();
    const { home, getTerminalRows } = this.deps;
    const chosen = await ctx.ui.custom<string | undefined>(
      (_tui: TUI, theme: Theme, _keybindings, done) =>
        new NazozokcPiSessions(
          theme,
          done,
          sessions,
          current,
          home,
          getTerminalRows,
        ),
      SCREEN_OPTIONS,
    );
    if (chosen && chosen !== current) await ctx.switchSession(chosen);
  }
}
