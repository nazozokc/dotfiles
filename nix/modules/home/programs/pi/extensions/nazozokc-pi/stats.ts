/**
 * nazozokc-pi extension — stats dashboard overlay.
 *
 * A read-only screen opened with `alt+s` or `/nazozokc-pi stats`. It expands
 * the compact panel/sidebar readouts into a full breakdown: model limits,
 * context pressure, token and cost totals, tool inventory and recent activity.
 */

import type { Theme } from "@earendil-works/pi-coding-agent";
import type { Component } from "@earendil-works/pi-tui";
import { matchesKey } from "@earendil-works/pi-tui";

import { boxBottom, boxDivider, boxLabelRow, boxRow, boxTop } from "./box.ts";
import {
  formatCost,
  formatDuration,
  formatTokens,
  makeBar,
} from "./format.ts";
import { contextDetailFragment } from "./render.ts";
import type { NazozokcPiData } from "./types.ts";

const LABEL_WIDTH = 11;
const BAR_WIDTH = 24;

export class NazozokcPiStats implements Component {
  focused = false;

  private readonly getData: () => NazozokcPiData | null;
  private readonly getTheme: () => Theme;
  private readonly done: (result: undefined) => void;
  private readonly getTerminalRows: (() => number | undefined) | undefined;

  constructor(
    getData: () => NazozokcPiData | null,
    getTheme: () => Theme,
    done: (result: undefined) => void,
    getTerminalRows?: () => number | undefined,
  ) {
    this.getData = getData;
    this.getTheme = getTheme;
    this.done = done;
    this.getTerminalRows = getTerminalRows;
  }

  invalidate(): void {
    // Stateless: renders fresh from getData() each call.
  }

  handleInput(data: string): void {
    if (matchesKey(data, "escape") || data === "q" || data === "Q") {
      this.done(undefined);
    }
  }

  render(width: number): string[] {
    const theme = this.getTheme();
    const data = this.getData();
    const body: string[] = [];
    const row = (l: string, v: string) =>
      body.push(boxLabelRow(theme, width, l, v, LABEL_WIDTH));
    const divider = () => body.push(boxDivider(theme, width));

    if (!data) {
      body.push(boxRow(theme, width, theme.fg("dim", " no session data")));
      return [
        boxTop(theme, width, "π nazozokc-pi · stats"),
        ...body,
        boxBottom(theme, width),
      ];
    }

    const s = data.stats;
    const ctx = data.context;

    row("model", theme.fg("text", data.model?.name || data.model?.id || "no-model"));
    row("provider", theme.fg("muted", data.model?.provider ?? "—"));
    row(
      "thinking",
      data.model?.reasoning
        ? theme.fg("muted", data.thinkingLevel || "off")
        : theme.fg("dim", "n/a"),
    );
    row("limits", contextDetailFragment(theme, data));
    divider();

    const percent = ctx.percent === null ? "?" : `${ctx.percent.toFixed(1)}%`;
    const used =
      ctx.tokens === null
        ? theme.fg("dim", "tokens unknown")
        : theme.fg(
            "muted",
            `${formatTokens(ctx.tokens)} / ${formatTokens(ctx.contextWindow)}`,
          );
    row(
      "context",
      `${theme.fg("success", makeBar((ctx.percent ?? 0) / 100, BAR_WIDTH))} ${theme.fg("muted", percent)} ${used}`,
    );
    row(
      "tokens",
      theme.fg("muted", `↑${formatTokens(s.input)} ↓${formatTokens(s.output)}`),
    );
    row(
      "cache",
      theme.fg(
        "muted",
        `R${formatTokens(s.cacheRead)} W${formatTokens(s.cacheWrite)}${
          s.cacheHitRate === null
            ? ""
            : ` · ${theme.fg("dim", `${s.cacheHitRate.toFixed(0)}% hit`)}`
        }`,
      ),
    );
    row("cost", theme.fg("muted", formatCost(s.cost)));
    divider();

    row("messages", theme.fg("muted", String(s.messages)));
    row("tool calls", theme.fg("muted", String(s.toolCalls)));
    row(
      "tools",
      `${theme.fg("muted", `${data.tools.active}/${data.tools.total}`)}${
        data.tools.mcpServers > 0
          ? theme.fg("dim", ` · mcp ${data.tools.mcpServers}srv/${data.tools.mcp}t`)
          : ""
      }`,
    );
    row(
      "recent",
      data.recentTools.length > 0
        ? theme.fg("muted", data.recentTools.join(", "))
        : theme.fg("dim", "none yet"),
    );
    divider();

    row("session", theme.fg("text", data.sessionName ?? "—"));
    row("id", theme.fg("dim", data.sessionId.slice(0, 16)));
    row("elapsed", theme.fg("muted", this.elapsed(data)));
    row("started", theme.fg("dim", this.startedAt(data)));
    row("compact", theme.fg("dim", data.autoCompact ? "auto" : "manual"));
    row("providers", theme.fg("dim", String(data.providerCount)));

    const maxRows = this.maxRows();
    const shown =
      body.length <= maxRows
        ? body
        : [
            ...body.slice(0, Math.max(0, maxRows - 1)),
            boxRow(
              theme,
              width,
              theme.fg("dim", ` … ${body.length - (maxRows - 1)} more`),
            ),
          ];
    return [
      boxTop(theme, width, "π nazozokc-pi · stats"),
      ...shown,
      boxRow(theme, width, theme.fg("dim", " esc / q to close")),
      boxBottom(theme, width),
    ];
  }

  private elapsed(data: NazozokcPiData): string {
    if (data.sessionStartedAt === null) return "—";
    return formatDuration(Date.now() - data.sessionStartedAt);
  }

  private startedAt(data: NazozokcPiData): string {
    if (data.sessionStartedAt === null) return "—";
    return new Date(data.sessionStartedAt).toLocaleTimeString();
  }

  /** Leave room for the top/bottom rules and the footer hint. */
  private maxRows(): number {
    const rows = this.getTerminalRows?.();
    if (!rows || rows <= 0) return Number.POSITIVE_INFINITY;
    return Math.max(4, rows - 3);
  }
}
