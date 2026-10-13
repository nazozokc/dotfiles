/**
 * nazozokc-pi extension — input editor.
 *
 * Extends Pi's `CustomEditor` (so app keybindings, autocomplete, paste and the
 * embedded working status keep working) and decorates the top border with the
 * brand glyph and a live model/context readout. While the agent is streaming
 * the base implementation owns the border so the working status stays visible.
 */

import type { KeybindingsManager, Theme } from "@earendil-works/pi-coding-agent";
import { CustomEditor } from "@earendil-works/pi-coding-agent";
import { visibleWidth } from "@earendil-works/pi-tui";
import type { EditorTheme, TUI } from "@earendil-works/pi-tui";

import type { NazozokcPiData } from "./types.ts";

type WorkingIndicator = Parameters<CustomEditor["setWorkingStatusIndicator"]>[0];

export class NazozokcPiEditor extends CustomEditor {
  private working = false;
  private readonly getData: () => NazozokcPiData | null;
  private readonly getTheme: () => Theme;

  constructor(
    tui: TUI,
    theme: EditorTheme,
    keybindings: KeybindingsManager,
    getData: () => NazozokcPiData | null,
    getTheme: () => Theme,
  ) {
    super(tui, theme, keybindings, { embedWorkingStatus: true });
    this.getData = getData;
    this.getTheme = getTheme;
  }

  setWorkingStatusIndicator(indicator: WorkingIndicator): void {
    this.working = indicator !== undefined;
    super.setWorkingStatusIndicator(indicator);
  }

  protected renderTopBorder(width: number, hiddenLineCount: number): string {
    if (this.working || hiddenLineCount > 0 || width < 16) {
      return super.renderTopBorder(width, hiddenLineCount);
    }
    const theme = this.getTheme();
    const data = this.getData();
    const brand = theme.fg("accent", "π");
    const right = this.rightLabel(theme, data);
    const brandWidth = visibleWidth(brand);
    const rightWidth = visibleWidth(right);
    if (rightWidth === 0 || brandWidth + rightWidth + 2 > width) {
      return super.renderTopBorder(width, hiddenLineCount);
    }
    const dashes = width - brandWidth - rightWidth - 1;
    return brand + this.borderColor("─".repeat(dashes)) + " " + right;
  }

  private rightLabel(theme: Theme, data: NazozokcPiData | null): string {
    if (!data) return "";
    const parts: string[] = [];
    parts.push(theme.fg("muted", data.model?.name || data.model?.id || "no-model"));
    if (data.model?.reasoning) parts.push(theme.fg("dim", data.thinkingLevel || "off"));
    if (data.context.percent !== null) {
      const token = data.context.percent > 90 ? "error" : data.context.percent > 70 ? "warning" : "dim";
      parts.push(theme.fg(token, `${data.context.percent.toFixed(0)}%`));
    }
    return parts.join(theme.fg("dim", " · "));
  }
}
