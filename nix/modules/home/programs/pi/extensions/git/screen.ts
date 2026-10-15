/**
 * git extension — overlay screen for `/git status`, `/git log`, `/git diff`.
 *
 * A read-only, self-contained bordered overlay. Content lines are computed by
 * the command handler (after running git) and passed in; the component only
 * frames and clamps them to the terminal.
 */

import type { ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import type { Component, TUI } from "@earendil-works/pi-tui";
import {
  matchesKey,
  truncateToWidth,
  visibleWidth,
} from "@earendil-works/pi-tui";

function border(theme: Theme, text: string): string {
  return theme.fg("border", text);
}

function fit(text: string, width: number): string {
  if (width <= 0) return "";
  return truncateToWidth(text, width, "…");
}

function top(theme: Theme, width: number, title: string): string {
  if (width < 4) return border(theme, fit("╭╮", width));
  const label = theme.bold(theme.fg("accent", fit(` ${title} `, width - 3)));
  const fill = Math.max(0, width - 3 - visibleWidth(label));
  return border(theme, "╭─") + label + border(theme, "─".repeat(fill) + "╮");
}

function bottom(theme: Theme, width: number): string {
  if (width < 2) return border(theme, fit("╰╯", width));
  return border(theme, "╰" + "─".repeat(width - 2) + "╯");
}

function row(theme: Theme, width: number, content: string): string {
  if (width < 2) return border(theme, fit("││", width));
  const inner = width - 2;
  const padded =
    content + " ".repeat(Math.max(0, inner - visibleWidth(content)));
  return border(theme, "│") + fit(padded, inner) + border(theme, "│");
}

export class GitScreen implements Component {
  focused = false;

  constructor(
    private readonly title: string,
    private readonly lines: readonly string[],
    private readonly getTheme: () => Theme,
    private readonly done: (result: undefined) => void,
    private readonly getRows: () => number | undefined,
  ) {}

  invalidate(): void {
    // Stateless: renders fresh from the fixed line list each call.
  }

  handleInput(data: string): void {
    if (matchesKey(data, "escape") || data === "q" || data === "Q") {
      this.done(undefined);
    }
  }

  render(width: number): string[] {
    const theme = this.getTheme();
    const maxRows = this.maxRows();
    const shown = this.lines.slice(0, Math.max(0, maxRows));
    const out = [top(theme, width, this.title)];
    for (const line of shown) {
      out.push(row(theme, width, " " + theme.fg("text", line)));
    }
    if (this.lines.length > shown.length) {
      out.push(
        row(
          theme,
          width,
          theme.fg("dim", ` … ${this.lines.length - shown.length} more`),
        ),
      );
    }
    out.push(row(theme, width, theme.fg("dim", " esc / q to close")));
    out.push(bottom(theme, width));
    return out;
  }

  /** Leave room for the top rule, hint row, truncation row and bottom rule. */
  private maxRows(): number {
    const rows = this.getRows();
    if (!rows || rows <= 0) return Number.POSITIVE_INFINITY;
    return Math.max(2, rows - 4);
  }
}

/** Open a centered git overlay with pre-rendered plain-text lines. */
export function openGitScreen(
  ctx: ExtensionContext,
  title: string,
  lines: readonly string[],
): void {
  void ctx.ui.custom<undefined>(
    (tui: TUI, theme: Theme, _keybindings, done) =>
      new GitScreen(
        title,
        lines,
        () => theme,
        done,
        () => tui.terminal.rows,
      ),
    {
      overlay: true,
      overlayOptions: {
        anchor: "center" as const,
        width: "80%" as const,
        maxHeight: "85%" as const,
        margin: 1,
      },
    },
  );
}
