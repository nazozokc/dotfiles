/**
 * nazozokc-pi extension — sidebar.
 *
 * A vertically stacked readout rendered as a non-capturing overlay anchored to
 * the top-right, so it never steals keyboard focus from the editor. Toggled
 * with `alt+h` or `/nazozokc-pi sidebar`; the overlay lifecycle is owned by
 * `sidebar-host.ts`.
 */

import type { Theme } from "@earendil-works/pi-coding-agent";
import type { Component } from "@earendil-works/pi-tui";

import { boxBottom, boxDivider, boxLabelRow, boxTop } from "./box.ts";
import { formatTokens, shortenHome } from "./format.ts";
import {
  activityFragment,
  contextFragment,
  elapsedFragment,
  sanitizeStatus,
  toolsCountFragment,
  toolsFragment,
} from "./render.ts";
import type { NazozokcPiData } from "./types.ts";

const LABEL_WIDTH = 9;
const BAR_WIDTH = 12;

/**
 * Rows reserved at the bottom of the screen for the input dock (panel + editor
 * + footer). The sidebar is anchored to the top, so it must stop above this
 * band or it would cover the input field on shorter terminals.
 */
const DOCK_RESERVE = 8;
const MIN_SIDEBAR_ROWS = 6;

export class NazozokcPiSidebar implements Component {
  private readonly getData: () => NazozokcPiData | null;
  private readonly getTheme: () => Theme;
  private readonly home: string | undefined;
  private readonly getTerminalRows: (() => number | undefined) | undefined;

  constructor(
    getData: () => NazozokcPiData | null,
    getTheme: () => Theme,
    home: string | undefined,
    getTerminalRows?: () => number | undefined,
  ) {
    this.getData = getData;
    this.getTheme = getTheme;
    this.home = home;
    this.getTerminalRows = getTerminalRows;
  }

  invalidate(): void {
    // Stateless: renders fresh from getData() each call.
  }

  /** Largest height that still leaves the input dock uncovered. */
  private maxRows(): number {
    const rows = this.getTerminalRows?.();
    if (!rows || rows <= 0) return Number.POSITIVE_INFINITY;
    return Math.max(MIN_SIDEBAR_ROWS, rows - DOCK_RESERVE);
  }

  render(width: number): string[] {
    const theme = this.getTheme();
    const data = this.getData();
    if (!data) return [];

    const middle: string[] = [];

    const push = (label: string, value: string): void => {
      middle.push(boxLabelRow(theme, width, label, value, LABEL_WIDTH));
    };

    // Session
    const branch = data.branch ? ` ${theme.fg("success", data.branch)}` : "";
    push("session", theme.fg("text", data.sessionName ?? "—") + branch);
    push("id", theme.fg("dim", data.sessionId.slice(0, 12)));
    push("cwd", theme.fg("text", shortenHome(data.cwd, this.home)));
    push("elapsed", elapsedFragment(theme, data));
    middle.push(boxDivider(theme, width));

    // Model
    push(
      "model",
      theme.fg("text", data.model?.name || data.model?.id || "no-model"),
    );
    push("provider", theme.fg("muted", data.model?.provider ?? "—"));
    push(
      "thinking",
      data.model?.reasoning
        ? theme.fg("muted", data.thinkingLevel || "off")
        : theme.fg("dim", "n/a"),
    );
    push(
      "out",
      data.model?.maxTokens
        ? theme.fg("dim", formatTokens(data.model.maxTokens))
        : theme.fg("dim", "—"),
    );
    middle.push(boxDivider(theme, width));

    // Context + tokens + cost
    push("ctx", contextFragment(theme, data, BAR_WIDTH));
    push(
      "tokens",
      [
        theme.fg("muted", `↑${formatTokens(data.stats.input)}`),
        theme.fg("muted", `↓${formatTokens(data.stats.output)}`),
        theme.fg("dim", `R${formatTokens(data.stats.cacheRead)}`),
        theme.fg("dim", `W${formatTokens(data.stats.cacheWrite)}`),
      ].join(" "),
    );
    push(
      "cache",
      data.stats.cacheHitRate === null
        ? theme.fg("dim", "—")
        : theme.fg("muted", `${data.stats.cacheHitRate.toFixed(0)}% hit`),
    );
    push("cost", theme.fg("muted", `$${data.stats.cost.toFixed(3)}`));
    push(
      "calls",
      theme.fg(
        "dim",
        `${data.stats.messages} msg · ${data.stats.toolCalls} tools`,
      ),
    );
    middle.push(boxDivider(theme, width));

    // Activity
    push("activity", activityFragment(theme, data));
    push("recent", toolsFragment(theme, data));
    push("compact", theme.fg("dim", data.autoCompact ? "auto" : "manual"));
    push("providers", theme.fg("dim", String(data.providerCount)));
    push("tools", toolsCountFragment(theme, data));

    // Extension statuses
    if (data.statuses.length > 0) {
      middle.push(boxDivider(theme, width));
      for (const status of [...data.statuses].sort((a, b) =>
        a.key.localeCompare(b.key),
      )) {
        push(status.key.slice(0, LABEL_WIDTH), sanitizeStatus(status.text));
      }
    }

    // Keep the input dock clear: drop the lowest-priority rows (which sit at
    // the bottom, nearest the input) and mark the cut with an ellipsis.
    const cap = this.maxRows();
    const budget = cap === Number.POSITIVE_INFINITY ? cap : cap - 2;
    if (middle.length <= budget) {
      return [
        boxTop(theme, width, "NAZOZOKC-PI"),
        ...middle,
        boxBottom(theme, width),
      ];
    }
    const shown = shownRows(middle, budget);
    return [
      boxTop(theme, width, "NAZOZOKC-PI"),
      ...shown,
      boxLabelRow(theme, width, "…", theme.fg("dim", "truncated"), LABEL_WIDTH),
      boxBottom(theme, width),
    ];
  }
}

/** Keep as many rows as fit, but never leave a divider as the last row. */
function shownRows(rows: string[], budget: number): string[] {
  if (budget <= 0) return [];
  let count = Math.max(0, budget - 1);
  while (count > 0 && rows[count - 1].includes("├")) count -= 1;
  return rows.slice(0, count);
}
