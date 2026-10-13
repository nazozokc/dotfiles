/**
 * nazozokc-pi extension — themed view fragments.
 *
 * Every surface (header, panel, footer, sidebar) composes these helpers so the
 * same data reads the same way everywhere. All helpers return (ANSI-styled)
 * strings; callers place them with the width-aware helpers from `format.ts`.
 */

import type { Theme, ThemeColor } from "@earendil-works/pi-coding-agent";

import {
  fit,
  formatCost,
  formatDuration,
  formatTokens,
  joinParts,
  makeBar,
  shortenHome,
} from "./format.ts";
import type { NazozokcPiData } from "./types.ts";

const THINK_TOKEN: Record<string, ThemeColor> = {
  off: "thinkingOff",
  minimal: "thinkingMinimal",
  low: "thinkingLow",
  medium: "thinkingMedium",
  high: "thinkingHigh",
  xhigh: "thinkingXhigh",
  max: "thinkingMax",
};

/** Color used for the context bar/percentage by pressure. */
function contextColor(percent: number | null): ThemeColor {
  if (percent !== null && percent > 90) return "error";
  if (percent !== null && percent > 70) return "warning";
  return "success";
}

/** Last path segment, for a compact title. */
function tailSegment(path: string): string {
  const trimmed = path.replace(/[/\\]+$/, "");
  const parts = trimmed.split(/[/\\]/);
  return parts[parts.length - 1] || trimmed || path;
}

/** Model name, prefixed with the provider when several are available. */
export function modelFragment(theme: Theme, data: NazozokcPiData): string {
  if (!data.model) return theme.fg("dim", "no-model");
  const name = theme.bold(theme.fg("text", data.model.name || data.model.id));
  if (data.providerCount > 1) {
    return `${theme.fg("dim", `(${data.model.provider})`)} ${name}`;
  }
  return name;
}

/** Thinking level, colored by its token. */
export function thinkingFragment(
  theme: Theme,
  data: NazozokcPiData,
): string | null {
  if (!data.model?.reasoning) return null;
  const level = data.thinkingLevel || "off";
  const token = THINK_TOKEN[level] ?? "muted";
  return `${theme.fg("dim", "think ")}${theme.fg(token, level)}`;
}

/** Context bar + percentage + used/window tokens. */
export function contextFragment(
  theme: Theme,
  data: NazozokcPiData,
  barWidth: number,
): string {
  const { percent, tokens, contextWindow } = data.context;
  const color = contextColor(percent);
  const barText = theme.fg(color, makeBar((percent ?? 0) / 100, barWidth));
  const percentText = percent === null ? "?" : `${percent.toFixed(1)}%`;
  const usage =
    tokens === null
      ? `${theme.fg(color, percentText)}`
      : `${theme.fg(color, percentText)}${theme.fg("dim", ` ${formatTokens(tokens)}/${formatTokens(contextWindow)}`)}`;
  return `${barText} ${usage}`;
}

/** Aggregate token + cost line: ↑in ↓out R$cacheRead W$cacheWrite CH% $cost. */
export function statsFragment(theme: Theme, data: NazozokcPiData): string {
  const s = data.stats;
  const parts: string[] = [];
  if (s.input) parts.push(theme.fg("muted", `↑${formatTokens(s.input)}`));
  if (s.output) parts.push(theme.fg("muted", `↓${formatTokens(s.output)}`));
  if (s.cacheRead) parts.push(theme.fg("dim", `R${formatTokens(s.cacheRead)}`));
  if (s.cacheWrite)
    parts.push(theme.fg("dim", `W${formatTokens(s.cacheWrite)}`));
  if (s.cacheHitRate !== null)
    parts.push(theme.fg("dim", `CH${s.cacheHitRate.toFixed(0)}%`));
  if (s.cost) parts.push(theme.fg("muted", formatCost(s.cost)));
  if (s.toolCalls) parts.push(theme.fg("dim", `${s.toolCalls} tools`));
  return joinParts(parts, theme.fg("dim", " · "));
}

/** Session title: explicit name, else the cwd tail. */
export function sessionTitle(data: NazozokcPiData): string {
  return data.sessionName ?? tailSegment(data.cwd);
}

/** Location line: cwd (with ~) plus git branch and session name. */
export function locationFragment(
  theme: Theme,
  data: NazozokcPiData,
  home: string | undefined,
): string {
  const cwd = shortenHome(data.cwd, home);
  const parts = [theme.fg("text", cwd)];
  if (data.branch) parts.push(theme.fg("success", data.branch));
  return joinParts(parts, theme.fg("dim", " "));
}

/** Short activity summary: running tool / queued / ready. */
export function activityFragment(theme: Theme, data: NazozokcPiData): string {
  if (data.activeTool) {
    return `${theme.fg("warning", "●")} ${theme.fg("text", data.activeTool.name)}`;
  }
  if (data.pending) {
    return `${theme.fg("accent", "◐")} ${theme.fg("dim", "queued")}`;
  }
  return `${theme.fg("success", "●")} ${theme.fg("dim", "ready")}`;
}

/** Sanitized single-line status text (newlines/tabs collapsed). */
export function sanitizeStatus(text: string): string {
  return text
    .replace(/[\r\n\t]/g, " ")
    .replace(/ +/g, " ")
    .trim();
}

/** Extension statuses joined for a footer line, or null when none. */
export function statusesLine(
  theme: Theme,
  data: NazozokcPiData,
  width: number,
): string | null {
  if (data.statuses.length === 0) return null;
  const sorted = [...data.statuses].sort((a, b) => a.key.localeCompare(b.key));
  const joined = sorted
    .map((s) => sanitizeStatus(s.text))
    .join(theme.fg("dim", "  "));
  return fit(joined, width);
}

/** Elapsed time since the session started: "12m34s", or "—" when unknown. */
export function elapsedFragment(theme: Theme, data: NazozokcPiData): string {
  if (data.sessionStartedAt === null) return theme.fg("dim", "—");
  return theme.fg("muted", formatDuration(Date.now() - data.sessionStartedAt));
}

/** Tool inventory: active/total plus MCP servers/tools when any are present. */
export function toolsCountFragment(theme: Theme, data: NazozokcPiData): string {
  const t = data.tools;
  const parts = [theme.fg("muted", `${t.active}/${t.total} tools`)];
  if (t.mcpServers > 0) {
    parts.push(theme.fg("dim", `mcp ${t.mcpServers}srv/${t.mcp}t`));
  }
  return joinParts(parts, theme.fg("dim", " "));
}

/** Context-window and max-output detail: "200k ctx · 16k out". */
export function contextDetailFragment(
  theme: Theme,
  data: NazozokcPiData,
): string {
  const ctx = theme.fg(
    "dim",
    `${formatTokens(data.context.contextWindow)} ctx`,
  );
  const out = data.model?.maxTokens
    ? theme.fg("dim", `${formatTokens(data.model.maxTokens)} out`)
    : theme.fg("dim", "? out");
  return joinParts([ctx, out], theme.fg("dim", " · "));
}

/** Active/recent tool summary used by the sidebar. */
export function toolsFragment(theme: Theme, data: NazozokcPiData): string {
  if (data.activeTool) {
    return `${theme.fg("warning", "●")} ${theme.fg("text", data.activeTool.name)}`;
  }
  if (data.recentTools.length === 0) return theme.fg("dim", "none yet");
  return data.recentTools
    .map((t) => theme.fg("muted", t))
    .join(theme.fg("dim", "  "));
}
