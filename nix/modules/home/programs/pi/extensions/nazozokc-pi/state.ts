/**
 * nazozokc-pi extension — shared runtime state.
 *
 * Holds the live context captured from event handlers and the fallback theme
 * captured from the first component factory. Every surface reads its data and
 * theme through this object so the wiring stays out of the entry point.
 */

import type { ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";

import type { NazozokcPiController } from "./controller.ts";
import type { NazozokcPiData } from "./types.ts";

export class NazozokcPiState {
  private current: ExtensionContext | undefined;
  private fallback: Theme | undefined;

  constructor(private readonly controller: NazozokcPiController) {}

  /** The most recent context seen by an event handler. */
  readonly getCtx = (): ExtensionContext | undefined => this.current;

  /** The current snapshot, or null before the first session starts. */
  readonly getData = (): NazozokcPiData | null =>
    this.current ? this.controller.getData(this.current) : null;

  /** The live theme, falling back to a factory-provided one before that. */
  readonly getTheme = (): Theme =>
    this.current?.ui.theme ?? (this.fallback as Theme);

  /** Remember the latest context (called from every event handler). */
  track = (ctx: ExtensionContext): void => {
    this.current = ctx;
  };

  /** Remember a theme supplied by a surface factory. */
  setFallbackTheme = (theme: Theme): void => {
    this.fallback = theme;
  };

  /** Forget the context on session shutdown. */
  clear = (): void => {
    this.current = undefined;
  };
}
