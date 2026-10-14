/**
 * nazozokc-pi extension — sidebar overlay lifecycle.
 *
 * Owns the non-capturing top-right overlay that renders the sidebar: registering
 * it once per session, toggling it by hiding (never popping the overlay stack)
 * and dropping tracking across a session boundary. The component itself lives
 * in `sidebar.ts`.
 */

import type { ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import type { Component, OverlayHandle, TUI } from "@earendil-works/pi-tui";

import { NazozokcPiSidebar } from "./sidebar.ts";
import type { NazozokcPiState } from "./state.ts";

const SIDEBAR_WIDTH = 48;
const SIDEBAR_MIN_TERMINAL_WIDTH = 110;

export interface NazozokcPiSidebarDeps {
  state: NazozokcPiState;
  home: string | undefined;
  getTerminalRows: () => number | undefined;
}

export class NazozokcPiSidebarHost {
  private handle: OverlayHandle | null = null;
  private close: ((result: undefined) => void) | null = null;
  private visible = false;

  constructor(private readonly deps: NazozokcPiSidebarDeps) {}

  /** Toggle the sidebar, registering the overlay on first use. */
  toggle(ctx: ExtensionContext): void {
    if (!this.close) this.open(ctx);
    else this.setVisible(!this.visible);
  }

  /** Register the overlay once per session and make sure it is shown. */
  open(ctx: ExtensionContext): void {
    this.visible = true;
    if (this.close) {
      this.handle?.setHidden(false);
      return;
    }
    const { state, home, getTerminalRows } = this.deps;
    const component: Component = new NazozokcPiSidebar(
      state.getData,
      state.getTheme,
      home,
      getTerminalRows,
    );
    void ctx.ui
      .custom<undefined>(
        (_tui: TUI, theme: Theme, _keybindings, done) => {
          state.setFallbackTheme(theme);
          this.close = done;
          return {
            render: (width: number) => component.render(width),
            invalidate: () => component.invalidate?.(),
            dispose: () => {
              this.close = null;
              this.handle = null;
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
            this.handle = handle;
            // The handle resolves asynchronously; honor an early toggle-off.
            if (!this.visible) handle.setHidden(true);
          },
        },
      )
      .finally(() => {
        this.close = null;
        this.handle = null;
      });
  }

  /**
   * Drop tracking for the overlay. `resetExtensionUI()` (session switch/fork/
   * new, `/reload`) pops the overlay from the stack, so the handle and close
   * callback must not be trusted across a session boundary.
   */
  reset(): void {
    this.handle = null;
    this.close = null;
    this.visible = false;
  }

  /** Close the overlay (if any) and drop tracking, e.g. on shutdown. */
  dispose(): void {
    const done = this.close;
    this.reset();
    done?.(undefined);
  }

  /** Toggle by hiding the overlay, so the stack order stays untouched. */
  private setVisible(visible: boolean): void {
    this.visible = visible;
    this.handle?.setHidden(!visible);
  }
}
