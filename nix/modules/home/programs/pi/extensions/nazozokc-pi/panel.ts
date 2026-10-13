/**
 * nazozokc-pi extension — status panel.
 *
 * A two-line widget pinned above the editor: identity/activity on top, context
 * pressure and token/cost totals below. Kept to two lines so it never fights
 * the transcript for vertical space.
 */

import type { Theme } from "@earendil-works/pi-coding-agent";
import type { Component } from "@earendil-works/pi-tui";

import { leftRight } from "./format.ts";
import { activityFragment, contextFragment, locationFragment, statsFragment } from "./render.ts";
import type { NazozokcPiData } from "./types.ts";

const RULE = "▌";

export class NazozokcPiPanel implements Component {
  private readonly getData: () => NazozokcPiData | null;
  private readonly getTheme: () => Theme;
  private readonly home: string | undefined;

  constructor(getData: () => NazozokcPiData | null, getTheme: () => Theme, home: string | undefined) {
    this.getData = getData;
    this.getTheme = getTheme;
    this.home = home;
  }

  invalidate(): void {
    // Stateless: renders fresh from getData() each call.
  }

  render(width: number): string[] {
    const theme = this.getTheme();
    const data = this.getData();
    if (!data) return [];

    const barWidth = Math.min(16, Math.max(6, Math.floor(width * 0.12)));
    const title = `${" ".repeat(1)}${theme.fg("accent", RULE)} ${theme.bold(theme.fg("text", data.sessionName ?? "session"))}`;
    const identity =
      width >= 56
        ? `${title}${theme.fg("dim", "  ")}${locationFragment(theme, data, this.home)}`
        : title;
    const line1 = leftRight(identity, activityFragment(theme, data), width);

    const context = `${" ".repeat(3)}${contextFragment(theme, data, barWidth)}`;
    const stats = width >= 72 ? `${theme.fg("dim", "  ·  ")}${statsFragment(theme, data)}` : "";
    const auto = theme.fg("dim", data.autoCompact ? "auto" : "manual");
    const line2 = leftRight(`${context}${stats}`, auto, width);

    return [line1, line2];
  }
}
