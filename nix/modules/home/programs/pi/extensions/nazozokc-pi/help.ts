/**
 * nazozokc-pi extension — help / cheatsheet overlay.
 *
 * A read-only screen opened with `alt+i` or `/nazozokc-pi help`. It shows the
 * current model/session identity, the nazozokc-pi shortcuts, pi essentials and
 * the slash commands available in this session.
 */

import type { Theme } from "@earendil-works/pi-coding-agent";
import type { Component } from "@earendil-works/pi-tui";
import { matchesKey, visibleWidth } from "@earendil-works/pi-tui";

import { boxBottom, boxDivider, boxLabelRow, boxRow, boxTop } from "./box.ts";
import { fit } from "./format.ts";
import {
  contextFragment,
  elapsedFragment,
  modelFragment,
  sessionTitle,
} from "./render.ts";
import type { NazozokcPiData } from "./types.ts";

const LABEL_WIDTH = 10;
const BAR_WIDTH = 10;

const SHORTCUTS: Array<[string, string]> = [
  ["alt+h", "toggle sidebar"],
  ["alt+i", "this help"],
  ["alt+s", "stats dashboard"],
  ["esc / q", "close this screen"],
  ["tab", "cycle agent mode"],
  ["shift+tab", "cycle thinking level"],
  ["ctrl+l", "select model"],
  ["ctrl+o", "expand tool output"],
  ["ctrl+t", "collapse thinking"],
  ["ctrl+g", "external editor"],
];

export interface HelpCommand {
  name: string;
  description?: string;
}

export class NazozokcPiHelp implements Component {
  focused = false;

  private readonly getData: () => NazozokcPiData | null;
  private readonly getTheme: () => Theme;
  private readonly home: string | undefined;
  private readonly commands: HelpCommand[];
  private readonly done: (result: undefined) => void;
  private readonly getTerminalRows: (() => number | undefined) | undefined;

  constructor(
    getData: () => NazozokcPiData | null,
    getTheme: () => Theme,
    home: string | undefined,
    commands: HelpCommand[],
    done: (result: undefined) => void,
    getTerminalRows?: () => number | undefined,
  ) {
    this.getData = getData;
    this.getTheme = getTheme;
    this.home = home;
    this.commands = commands;
    this.done = done;
    this.getTerminalRows = getTerminalRows;
  }

  invalidate(): void {
    // Stateless: renders fresh from getData() each call.
  }

  handleInput(data: string): void {
    if (matchesKey(data, "escape") || data === "q" || data === "Q") {
      this.done(undefined);
    }
  }

  render(width: number): string[] {
    const theme = this.getTheme();
    const data = this.getData();
    const body: string[] = [];
    const label = (l: string, v: string) =>
      body.push(boxLabelRow(theme, width, l, v, LABEL_WIDTH));
    const divider = () => body.push(boxDivider(theme, width));

    if (data) {
      label("model", modelFragment(theme, data));
      label(
        "thinking",
        data.model?.reasoning
          ? theme.fg("muted", data.thinkingLevel || "off")
          : theme.fg("dim", "n/a"),
      );
      label("session", theme.fg("text", sessionTitle(data)));
      label("cwd", theme.fg("text", this.short(data.cwd)));
      label("elapsed", elapsedFragment(theme, data));
      label("ctx", contextFragment(theme, data, BAR_WIDTH));
    } else {
      body.push(boxRow(theme, width, theme.fg("dim", " no session data")));
    }

    divider();
    for (const [key, description] of SHORTCUTS) {
      body.push(
        boxRow(
          theme,
          width,
          ` ${theme.fg("accent", key.padEnd(10))} ${theme.fg("text", description)}`,
        ),
      );
    }

    divider();
    for (const command of this.commands) {
      const name = theme.fg("accent", `/${command.name}`);
      const gap = " ".repeat(Math.max(1, 22 - 1 - visibleWidth(command.name)));
      const description = command.description
        ? theme.fg("muted", fit(command.description, Math.max(0, width - 26)))
        : "";
      body.push(boxRow(theme, width, ` ${name}${gap}${description}`));
    }

    const maxRows = this.maxRows();
    const shown =
      body.length <= maxRows
        ? body
        : [
            ...body.slice(0, Math.max(0, maxRows - 1)),
            boxRow(
              theme,
              width,
              theme.fg("dim", ` … ${body.length - (maxRows - 1)} more`),
            ),
          ];
    return [
      boxTop(theme, width, "π nazozokc-pi · help"),
      ...shown,
      boxRow(theme, width, theme.fg("dim", " esc / q to close")),
      boxBottom(theme, width),
    ];
  }

  private short(path: string): string {
    if (!this.home) return path;
    if (path === this.home) return "~";
    if (path.startsWith(this.home + "/"))
      return "~" + path.slice(this.home.length);
    return path;
  }

  /** Leave room for the top/bottom rules and the footer hint. */
  private maxRows(): number {
    const rows = this.getTerminalRows?.();
    if (!rows || rows <= 0) return Number.POSITIVE_INFINITY;
    return Math.max(4, rows - 3);
  }
}
