/**
 * nazozokc-pi extension — bordered box primitives.
 *
 * Shared frame helpers for every bordered surface: the on-demand overlay
 * screens (help, stats, sessions) and the sidebar.
 */

import type { Theme } from "@earendil-works/pi-coding-agent";
import { visibleWidth } from "@earendil-works/pi-tui";

import { fit } from "./format.ts";

function border(theme: Theme, text: string): string {
  return theme.fg("border", text);
}

/** Top rule with a title: `╭─ TITLE ────╮` (the title is fitted to the width). */
export function boxTop(theme: Theme, width: number, title: string): string {
  if (width < 4) return border(theme, fit("╭╮", width));
  const label = theme.bold(theme.fg("accent", fit(` ${title} `, width - 3)));
  const fill = Math.max(0, width - 3 - visibleWidth(label));
  return border(theme, "╭─") + label + border(theme, "─".repeat(fill) + "╮");
}

/** Middle divider: `├────┤`. */
export function boxDivider(theme: Theme, width: number): string {
  return border(theme, "├" + "─".repeat(Math.max(0, width - 2)) + "┤");
}

/** Bottom rule: `╰────╯`. */
export function boxBottom(theme: Theme, width: number): string {
  return border(theme, "╰" + "─".repeat(Math.max(0, width - 2)) + "╯");
}

/** One content row, padded/fitted to the inner width: `│ content │`. */
export function boxRow(theme: Theme, width: number, content: string): string {
  const inner = Math.max(0, width - 2);
  const padded =
    content + " ".repeat(Math.max(0, inner - visibleWidth(content)));
  return border(theme, "│") + fit(padded, inner) + border(theme, "│");
}

/** Label/value row with a fixed label gutter, like the sidebar. */
export function boxLabelRow(
  theme: Theme,
  width: number,
  label: string,
  value: string,
  labelWidth: number,
): string {
  const inner = Math.max(0, width - 4);
  const lw = Math.min(labelWidth, Math.max(0, inner - 1));
  const vw = Math.max(0, inner - lw - 1);
  const labelText = theme.fg("muted", label.padEnd(lw).slice(0, lw));
  const content = " " + labelText + " " + fit(value, vw);
  return boxRow(theme, width, content);
}
