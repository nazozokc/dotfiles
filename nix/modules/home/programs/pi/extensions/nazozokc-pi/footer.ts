/**
 * nazozokc-pi extension — footer.
 *
 * Replaces the built-in footer. It intentionally does little work per frame:
 * only location, the active model/thinking level and extension statuses
 * (e.g. codex-usage). The heavier token/context readouts live in the panel,
 * which renders less often than the footer.
 */

import type {
  ExtensionContext,
  ReadonlyFooterDataProvider,
  Theme,
} from "@earendil-works/pi-coding-agent";
import type { Component } from "@earendil-works/pi-tui";

import { fit, formatDuration, leftRight, shortenHome } from "./format.ts";
import { sanitizeStatus } from "./render.ts";

export class NazozokcPiFooter implements Component {
  private readonly getCtx: () => ExtensionContext | undefined;
  private readonly getTheme: () => Theme;
  private readonly footerData: ReadonlyFooterDataProvider;
  private readonly home: string | undefined;

  constructor(
    getCtx: () => ExtensionContext | undefined,
    getTheme: () => Theme,
    footerData: ReadonlyFooterDataProvider,
    home: string | undefined,
  ) {
    this.getCtx = getCtx;
    this.getTheme = getTheme;
    this.footerData = footerData;
    this.home = home;
  }

  invalidate(): void {
    // Stateless: renders fresh each call.
  }

  render(width: number): string[] {
    const theme = this.getTheme();
    const ctx = this.getCtx();
    const lines: string[] = [];

    if (ctx) {
      const location = shortenHome(ctx.cwd, this.home);
      const branch = this.footerData.getGitBranch();
      const name = ctx.sessionManager.getSessionName();
      const header = ctx.sessionManager.getHeader();
      const started = header ? Date.parse(header.timestamp) : Number.NaN;
      const elapsed = Number.isNaN(started)
        ? null
        : theme.fg("dim", `⏱ ${formatDuration(Date.now() - started)}`);
      const left = [
        theme.fg("text", location),
        branch ? theme.fg("success", branch) : null,
        name ? theme.fg("muted", `• ${name}`) : null,
        elapsed,
      ]
        .filter((p): p is string => Boolean(p))
        .join(theme.fg("dim", " "));

      const model = ctx.model
        ? `${theme.bold(theme.fg("text", ctx.model.name || ctx.model.id))}${
            ctx.model.reasoning
              ? theme.fg("dim", " · ") +
                theme.fg("muted", ctx.thinkingLevel ?? "off")
              : ""
          }`
        : theme.fg("dim", "no-model");

      lines.push(leftRight(left, model, width));
    }

    const statuses = this.statusLine(theme, width);
    if (statuses) lines.push(statuses);

    return lines;
  }

  private statusLine(theme: Theme, width: number): string | null {
    const entries = [...this.footerData.getExtensionStatuses()];
    if (entries.length === 0) return null;
    entries.sort(([a], [b]) => a.localeCompare(b));
    const joined = entries
      .map(([, text]) => sanitizeStatus(text))
      .join(theme.fg("dim", "  "));
    return fit(joined, width);
  }
}
