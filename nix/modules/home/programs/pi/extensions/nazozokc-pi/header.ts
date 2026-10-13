/**
 * nazozokc-pi extension — header.
 *
 * Replaces the built-in startup header with a compact identity card. It is
 * shown above the transcript at startup and reads live data so a resumed or
 * forked session reflects its own model/location.
 */

import type { Theme } from "@earendil-works/pi-coding-agent";
import { VERSION } from "@earendil-works/pi-coding-agent";
import type { Component } from "@earendil-works/pi-tui";

import { fit, leftRight } from "./format.ts";
import {
  activityFragment,
  locationFragment,
  modelFragment,
  thinkingFragment,
} from "./render.ts";
import type { NazozokcPiData } from "./types.ts";

const LEFT_INSET = 1;
const RULE = "▌";

export class NazozokcPiHeader implements Component {
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

  private rule(theme: Theme): string {
    return " ".repeat(LEFT_INSET) + theme.fg("accent", RULE) + " ";
  }

  render(width: number): string[] {
    const theme = this.getTheme();
    const data = this.getData();
    const inner = Math.max(1, width - LEFT_INSET - 2);

    if (!data) {
      return [this.rule(theme) + theme.bold(theme.fg("text", "π nazozokc-pi"))];
    }

    const brand = `${theme.bold(theme.fg("text", "π nazozokc-pi"))} ${theme.fg("dim", `v${VERSION}`)}`;
    const thinking = thinkingFragment(theme, data);
    const right = thinking
      ? `${modelFragment(theme, data)}  ${thinking}`
      : modelFragment(theme, data);

    return [
      this.rule(theme) + leftRight(brand, right, inner),
      this.rule(theme) + fit(locationFragment(theme, data, this.home), inner),
      this.rule(theme) +
        leftRight(
          `${activityFragment(theme, data)}${theme.fg("dim", "   /nazozokc-pi · alt+i help · alt+h sidebar")}`,
          theme.fg("dim", `session ${data.sessionId.slice(0, 8)}`),
          inner,
        ),
    ];
  }
}
