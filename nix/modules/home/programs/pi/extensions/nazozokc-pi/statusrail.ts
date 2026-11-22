/**
 * nazozokc-pi extension — persistent status rail.
 *
 * A single line below the editor that complements the three-line panel above
 * it: work-tree state, context headroom and a lightweight host readout. The
 * panel stays focused on session totals; this rail is the always-visible
 * "can I keep working?" glance. Width tiers drop the least useful sections
 * first so the line never wraps on narrow terminals.
 */

import type { Theme } from "@earendil-works/pi-coding-agent";
import type { Component } from "@earendil-works/pi-tui";

import {
  fit,
  formatCost,
  formatTokens,
  joinParts,
  leftRight,
} from "./format.ts";
import {
  gitFragment,
  hostFragment,
  pressureColor,
  ruleFragment,
  sectionDivider,
} from "./render.ts";
import type { NazozokcPiData } from "./types.ts";

const FULL_WIDTH = 110;
const DETAIL_WIDTH = 80;
const GIT_WIDTH = 50;

export class NazozokcPiStatusRail implements Component {
  private readonly getData: () => NazozokcPiData | null;
  private readonly getTheme: () => Theme;

  constructor(getData: () => NazozokcPiData | null, getTheme: () => Theme) {
    this.getData = getData;
    this.getTheme = getTheme;
  }

  invalidate(): void {
    // Stateless: renders fresh from getData() each call.
  }

  /** Context headroom with optional burn/cost detail. */
  private contextFragment(
    theme: Theme,
    data: NazozokcPiData,
    detailed: boolean,
  ): string {
    const { percent, remaining, turnsLeft } = data.context;
    const color = pressureColor(percent);
    const parts = [
      `${theme.fg("dim", "ctx")} ${theme.fg(color, percent === null ? "?" : `${percent.toFixed(0)}%`)}`,
    ];
    if (remaining !== null) {
      parts.push(theme.fg("dim", `${formatTokens(remaining)} left`));
    }
    if (detailed && turnsLeft !== null) {
      parts.push(theme.fg("muted", `≈${Math.min(turnsLeft, 999)} turns`));
    }
    if (detailed && data.stats.turnCost > 0) {
      parts.push(theme.fg("muted", `+${formatCost(data.stats.turnCost)}/turn`));
    }
    return joinParts(parts, theme.fg("dim", " "));
  }

  render(width: number): string[] {
    const data = this.getData();
    if (!data) return [];
    const theme = this.getTheme();
    const detailed = width >= DETAIL_WIDTH;

    const left =
      ruleFragment(theme) +
      (data.git && width >= GIT_WIDTH
        ? gitFragment(theme, data.git) + sectionDivider(theme)
        : "") +
      this.contextFragment(theme, data, detailed);

    const host = {
      ...data.host,
      load: width >= FULL_WIDTH ? data.host.load : null,
      memoryPercent: detailed ? data.host.memoryPercent : null,
    };
    const right = hostFragment(theme, host, data.now);

    return [fit(leftRight(left, right, width), width)];
  }
}
