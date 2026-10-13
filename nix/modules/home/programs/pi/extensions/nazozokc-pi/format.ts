/**
 * nazozokc-pi extension — formatting helpers.
 *
 * Pure string helpers with no theme dependency. All width-sensitive helpers
 * measure visible terminal columns (ANSI-aware) so styled fragments compose
 * correctly.
 */

import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

/** Compact token count: 1234 -> "1.2k", 12345 -> "12k", 1_200_000 -> "1.2M". */
export function formatTokens(n: number): string {
  if (!Number.isFinite(n) || n <= 0) return "0";
  if (n < 1000) return String(Math.round(n));
  if (n < 10_000) return `${(n / 1000).toFixed(1)}k`;
  if (n < 1_000_000) return `${Math.round(n / 1000)}k`;
  return `${(n / 1_000_000).toFixed(1)}M`;
}

/** Compact duration: 45s / 12m34s / 3h07m. */
export function formatDuration(ms: number): string {
  if (!Number.isFinite(ms) || ms < 0) return "—";
  const seconds = Math.floor(ms / 1000);
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const secs = seconds % 60;
  if (hours > 0) return `${hours}h${String(minutes).padStart(2, "0")}m`;
  if (minutes > 0) return `${minutes}m${String(secs).padStart(2, "0")}s`;
  return `${secs}s`;
}

/** Session cost: "$0.0042" / "<$0.001". */
export function formatCost(n: number): string {
  if (!Number.isFinite(n) || n <= 0) return "$0.000";
  if (n < 0.001) return "<$0.001";
  if (n < 1) return `$${n.toFixed(3)}`;
  return `$${n.toFixed(2)}`;
}

/** Percentage with one decimal, or "?" when unknown. */
export function formatPercent(p: number | null): string {
  return p === null ? "?" : `${p.toFixed(1)}%`;
}

/** Proportional bar made of block glyphs (each glyph is one cell wide). */
export function makeBar(ratio: number, width: number): string {
  const w = Math.max(1, Math.floor(width));
  const clamped = Number.isFinite(ratio) ? Math.max(0, Math.min(1, ratio)) : 0;
  const filled = Math.round(clamped * w);
  return "█".repeat(filled) + "░".repeat(w - filled);
}

/** Replace a leading home directory with "~". */
export function shortenHome(path: string, home: string | undefined): string {
  if (!home) return path;
  if (path === home) return "~";
  if (path.startsWith(home + "/")) return "~" + path.slice(home.length);
  return path;
}

/** Truncate an (ANSI-aware) string to a visible width. */
export function fit(text: string, width: number): string {
  if (width <= 0) return "";
  return truncateToWidth(text, width, "…");
}

/** Pad an (ANSI-aware) string with spaces to an exact visible width. */
export function padTo(text: string, width: number): string {
  const w = visibleWidth(text);
  if (w >= width) return fit(text, width);
  return text + " ".repeat(width - w);
}

/**
 * Place `left` and `right` on one line, filling the gap so the result is
 * exactly `width` visible columns. The left side is truncated first when space
 * runs out; the right side is preserved.
 */
export function leftRight(left: string, right: string, width: number): string {
  const lw = visibleWidth(left);
  const rw = visibleWidth(right);
  if (rw >= width) return fit(right, width);
  if (lw + rw + 1 <= width) {
    return left + " ".repeat(width - lw - rw) + right;
  }
  const avail = width - rw - 1;
  if (avail <= 0) return fit(right, width);
  return fit(left, avail) + " " + right;
}

/** Join non-empty fragments with a separator. */
export function joinParts(
  parts: Array<string | null | undefined>,
  sep: string,
): string {
  return parts.filter((p): p is string => Boolean(p && p.length > 0)).join(sep);
}

/** A single-cell block glyph for the context/usage bar. */
export function bar(ratio: number, width: number): string {
  return makeBar(ratio, width);
}
