/**
 * nazozokc-pi extension — session switcher overlay.
 *
 * Opened with `alt+o` or `/nazozokc-pi sessions`. Lists the recent sessions
 * (most recently modified first) and returns the chosen session path so the
 * command handler can call `ctx.switchSession()`.
 */

import type { SessionInfo, Theme } from "@earendil-works/pi-coding-agent";
import type { Component } from "@earendil-works/pi-tui";
import { matchesKey, visibleWidth } from "@earendil-works/pi-tui";

import { boxBottom, boxRow, boxTop } from "./box.ts";
import { fit } from "./format.ts";

const TIME_WIDTH = 8;

export class NazozokcPiSessions implements Component {
  focused = false;

  private readonly theme: Theme;
  private readonly done: (result: string | undefined) => void;
  private readonly home: string | undefined;
  private readonly currentPath: string | undefined;
  private readonly sessions: SessionInfo[];
  private readonly getTerminalRows: (() => number | undefined) | undefined;
  private selected = 0;

  constructor(
    theme: Theme,
    done: (result: string | undefined) => void,
    sessions: SessionInfo[],
    currentPath: string | undefined,
    home: string | undefined,
    getTerminalRows?: () => number | undefined,
  ) {
    this.theme = theme;
    this.done = done;
    this.sessions = sessions;
    this.currentPath = currentPath;
    this.home = home;
    this.getTerminalRows = getTerminalRows;
  }

  invalidate(): void {
    // Stateless.
  }

  handleInput(data: string): void {
    if (matchesKey(data, "escape") || data === "q" || data === "Q") {
      this.done(undefined);
      return;
    }
    if (matchesKey(data, "return") || matchesKey(data, "enter")) {
      const session = this.sessions[this.selected];
      this.done(session?.path);
      return;
    }
    if (matchesKey(data, "up") || data === "k") {
      this.selected = Math.max(0, this.selected - 1);
      return;
    }
    if (matchesKey(data, "down") || data === "j") {
      this.selected = Math.min(this.sessions.length - 1, this.selected + 1);
    }
  }

  render(width: number): string[] {
    const theme = this.theme;
    const lines: string[] = [boxTop(theme, width, "π nazozokc-pi · sessions")];

    if (this.sessions.length === 0) {
      lines.push(boxRow(theme, width, theme.fg("dim", " no sessions found")));
    } else {
      const window = this.window();
      const start = window.start;
      const end = window.end;
      for (let i = start; i < end; i++) {
        lines.push(
          this.row(theme, width, this.sessions[i], i === this.selected),
        );
      }
      if (start > 0) {
        lines.unshift(
          boxRow(theme, width, theme.fg("dim", ` ↑ ${start} newer`)),
        );
      }
      if (end < this.sessions.length) {
        lines.push(
          boxRow(
            theme,
            width,
            theme.fg("dim", ` ↓ ${this.sessions.length - end} older`),
          ),
        );
      }
    }

    lines.push(
      boxRow(
        theme,
        width,
        theme.fg("dim", " ↑↓ move · enter switch · esc close"),
      ),
    );
    lines.push(boxBottom(theme, width));
    return lines;
  }

  private row(
    theme: Theme,
    width: number,
    session: SessionInfo,
    selected: boolean,
  ): string {
    const marker = selected ? theme.fg("accent", "▶") : " ";
    const isCurrent = session.path === this.currentPath;
    const dot = isCurrent ? theme.fg("success", "●") : " ";
    const label = session.name || session.firstMessage || session.id;
    const cwd = this.shortCwd(session.cwd);
    const time = this.relative(session.modified);

    const suffix = `${theme.fg("dim", cwd)} ${theme.fg("dim", time)}`;
    const prefixWidth = 6; // " ▶ ● "
    const suffixWidth = visibleWidth(cwd) + 1 + TIME_WIDTH;
    const avail = Math.max(0, width - 2 - prefixWidth - suffixWidth);
    const labelText = selected
      ? theme.fg("text", fit(label, avail))
      : theme.fg("muted", fit(label, avail));

    const content = ` ${marker} ${dot} ${labelText}  ${suffix}`;
    return boxRow(theme, width, content);
  }

  private window(): { start: number; end: number } {
    const rows = this.getTerminalRows?.();
    const capacity = !rows || rows <= 0 ? 12 : Math.max(3, rows - 8);
    if (this.sessions.length <= capacity) {
      return { start: 0, end: this.sessions.length };
    }
    let start = Math.max(0, this.selected - Math.floor(capacity / 2));
    const end = Math.min(this.sessions.length, start + capacity);
    start = Math.max(0, end - capacity);
    return { start, end };
  }

  private shortCwd(cwd: string): string {
    if (!cwd) return "?";
    const path =
      this.home && cwd.startsWith(this.home)
        ? "~" + cwd.slice(this.home.length)
        : cwd;
    const parts = path.split("/").filter(Boolean);
    return parts.length <= 2
      ? path
      : `${parts[0]}/…/${parts[parts.length - 1]}`;
  }

  private relative(date: Date): string {
    const ms = Date.now() - new Date(date).getTime();
    if (!Number.isFinite(ms) || ms < 0) return "—".padEnd(TIME_WIDTH);
    const minutes = Math.floor(ms / 60000);
    if (minutes < 1) return "now".padEnd(TIME_WIDTH);
    if (minutes < 60) return `${minutes}m`.padEnd(TIME_WIDTH);
    const hours = Math.floor(minutes / 60);
    if (hours < 24) return `${hours}h`.padEnd(TIME_WIDTH);
    const days = Math.floor(hours / 24);
    return `${days}d`.padEnd(TIME_WIDTH);
  }
}
