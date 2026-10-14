/**
 * nazozokc-pi extension — surface installation.
 *
 * Installs the custom header, panel widget, footer and editor against the
 * interactive UI. Pi clears these on `resetExtensionUI()` (session switch/fork/
 * new, `/reload`), so they are (re)installed on every session start. The footer
 * goes first because only its factory receives the footer data provider that
 * the other surfaces rely on.
 */

import type {
  ExtensionContext,
  ReadonlyFooterDataProvider,
  Theme,
} from "@earendil-works/pi-coding-agent";
import type { TUI } from "@earendil-works/pi-tui";

import type { NazozokcPiController } from "./controller.ts";
import { NazozokcPiEditor } from "./editor.ts";
import { NazozokcPiFooter } from "./footer.ts";
import { NazozokcPiHeader } from "./header.ts";
import { NazozokcPiPanel } from "./panel.ts";
import type { NazozokcPiState } from "./state.ts";

const PANEL_KEY = "nazozokc-pi";

export class NazozokcPiSurfaces {
  private panelEnabled = true;

  constructor(
    private readonly state: NazozokcPiState,
    private readonly controller: NazozokcPiController,
    private readonly home: string | undefined,
  ) {}

  /** Install every surface. Footer first: it supplies the footer data provider. */
  installAll(ctx: ExtensionContext): void {
    this.installFooter(ctx);
    this.installHeader(ctx);
    this.installPanel(ctx);
    this.installEditor(ctx);
  }

  /** Toggle the panel widget and return its new state. */
  togglePanel(ctx: ExtensionContext): boolean {
    this.panelEnabled = !this.panelEnabled;
    this.installPanel(ctx);
    return this.panelEnabled;
  }

  private installPanel(ctx: ExtensionContext): void {
    if (!this.panelEnabled) {
      ctx.ui.setWidget(PANEL_KEY, undefined);
      return;
    }
    ctx.ui.setWidget(
      PANEL_KEY,
      (tui: TUI, theme: Theme) => {
        this.controller.attachTui(tui);
        this.state.setFallbackTheme(theme);
        return new NazozokcPiPanel(
          this.state.getData,
          this.state.getTheme,
          this.home,
        );
      },
      { placement: "aboveEditor" },
    );
  }

  private installHeader(ctx: ExtensionContext): void {
    ctx.ui.setHeader((tui: TUI, theme: Theme) => {
      this.controller.attachTui(tui);
      this.state.setFallbackTheme(theme);
      return new NazozokcPiHeader(
        this.state.getData,
        this.state.getTheme,
        this.home,
      );
    });
  }

  private installFooter(ctx: ExtensionContext): void {
    ctx.ui.setFooter(
      (tui: TUI, theme: Theme, footerData: ReadonlyFooterDataProvider) => {
        this.controller.attachTui(tui);
        this.controller.attachFooterData(footerData);
        this.state.setFallbackTheme(theme);
        return new NazozokcPiFooter(
          this.state.getCtx,
          this.state.getTheme,
          footerData,
          this.home,
        );
      },
    );
  }

  private installEditor(ctx: ExtensionContext): void {
    ctx.ui.setEditorComponent((tui: TUI, theme, keybindings) => {
      this.controller.attachTui(tui);
      return new NazozokcPiEditor(
        tui,
        theme,
        keybindings,
        this.state.getData,
        this.state.getTheme,
      );
    });
  }
}
