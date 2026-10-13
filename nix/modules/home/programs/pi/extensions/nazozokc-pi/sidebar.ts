/**
 * nazozokc-pi extension — sidebar.
 *
 * A vertically stacked readout rendered as a non-capturing overlay anchored to
 * the right edge, so it never steals keyboard focus from the editor. Toggled
 * with `alt+h` or `/nazozokc-pi sidebar`.
 */

import type { Theme } from "@earendil-works/pi-coding-agent";
import type { Component } from "@earendil-works/pi-tui";
import { visibleWidth } from "@earendil-works/pi-tui";

import { fit, formatTokens, shortenHome } from "./format.ts";
import {
  activityFragment,
  contextFragment,
  sanitizeStatus,
  toolsFragment,
} from "./render.ts";
import type { NazozokcPiData } from "./types.ts";

const LABEL_WIDTH = 9;
const BAR_WIDTH = 12;

export class NazozokcPiSidebar implements Component {
  private readonly getData: () => NazozokcPiData | null;
  private readonly getTheme: () => Theme;
  private readonly home: string | undefined;

  constructor(
    getData: () => NazozokcPiData | null,
    getTheme: () => Theme,
    home: string | undefined,
  ) {
    this.getData = getData;
    this.getTheme = getTheme;
    this.home = home;
  }

  invalidate(): void {
    // Stateless: renders fresh from getData() each call.
  }

  private border(theme: Theme, text: string): string {
    return theme.fg("border", text);
  }

  private top(width: number, theme: Theme): string {
    const title = theme.bold(theme.fg("accent", " NAZOZOKC-PI "));
    const fill = Math.max(0, width - 3 - visibleWidth(title));
    return (
      this.border(theme, "╭─") +
      title +
      this.border(theme, "─".repeat(fill) + "╮")
    );
  }

  private divider(width: number, theme: Theme): string {
    return this.border(theme, "├" + "─".repeat(Math.max(0, width - 2)) + "┤");
  }

  private bottom(width: number, theme: Theme): string {
    return this.border(theme, "╰" + "─".repeat(Math.max(0, width - 2)) + "╯");
  }

  private row(
    width: number,
    theme: Theme,
    label: string,
    value: string,
  ): string {
    const inner = Math.max(0, width - 4);
    const labelWidth = Math.min(LABEL_WIDTH, Math.max(0, inner - 1));
    const valueWidth = Math.max(0, inner - labelWidth - 1);
    const labelText = theme.fg(
      "muted",
      label.padEnd(labelWidth).slice(0, labelWidth),
    );
    const valueText = truncate(value, valueWidth);
    const content = " " + labelText + " " + valueText;
    const padded =
      content + " ".repeat(Math.max(0, width - 2 - visibleWidth(content)));
    return (
      this.border(theme, "│") + fit(padded, width - 2) + this.border(theme, "│")
    );
  }

  render(width: number): string[] {
    const theme = this.getTheme();
    const data = this.getData();
    if (!data) return [];

    const lines: string[] = [this.top(width, theme)];

    const push = (label: string, value: string): void => {
      lines.push(this.row(width, theme, label, value));
    };

    // Session
    const branch = data.branch ? ` ${theme.fg("success", data.branch)}` : "";
    push("session", theme.fg("text", data.sessionName ?? "—") + branch);
    push("id", theme.fg("dim", data.sessionId.slice(0, 12)));
    push("cwd", theme.fg("text", shortenHome(data.cwd, this.home)));
    lines.push(this.divider(width, theme));

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
    lines.push(this.divider(width, theme));

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
    lines.push(this.divider(width, theme));

    // Activity
    push("activity", activityFragment(theme, data));
    push("recent", toolsFragment(theme, data));
    push("compact", theme.fg("dim", data.autoCompact ? "auto" : "manual"));
    push("providers", theme.fg("dim", String(data.providerCount)));

    // Extension statuses
    if (data.statuses.length > 0) {
      lines.push(this.divider(width, theme));
      for (const status of [...data.statuses].sort((a, b) =>
        a.key.localeCompare(b.key),
      )) {
        push(status.key.slice(0, LABEL_WIDTH), sanitizeStatus(status.text));
      }
    }

    lines.push(this.bottom(width, theme));
    return lines;
  }
}

function truncate(text: string, width: number): string {
  return fit(text, width);
}
