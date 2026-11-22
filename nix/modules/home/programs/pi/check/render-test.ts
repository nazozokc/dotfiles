/**
 * pi HUD render check.
 *
 * Renders every nazozokc-pi surface at the widths seen in real terminals and
 * asserts that no line exceeds the requested width. Fake theme methods return
 * the text argument, so a theme call that accidentally emits a color name
 * instead of content is caught as a width/layout failure.
 */
import assert from "node:assert/strict";
import { visibleWidth } from "@earendil-works/pi-tui";

import { NazozokcPiHeader } from "./extensions/nazozokc-pi/header.ts";
import { NazozokcPiPanel } from "./extensions/nazozokc-pi/panel.ts";
import { NazozokcPiSidebar } from "./extensions/nazozokc-pi/sidebar.ts";
import { NazozokcPiHelp } from "./extensions/nazozokc-pi/help.ts";
import { NazozokcPiStats } from "./extensions/nazozokc-pi/stats.ts";
import { NazozokcPiSessions } from "./extensions/nazozokc-pi/sessions.ts";

const theme = new Proxy(
  {},
  {
    get:
      () =>
      (...args: unknown[]) => {
        const text = args.length > 1 ? args[1] : args[0];
        return typeof text === "string" ? text : "";
      },
  },
) as any;

const noop = () => {};
const home = "/home/nazozokc";
const rows = () => 24;
const widths = [40, 60, 80, 120];

const data = {
  model: {
    id: "claude-sonnet-4-5",
    name: "Sonnet",
    provider: "anthropic",
    reasoning: true,
    contextWindow: 200000,
    maxTokens: 8192,
  },
  thinkingLevel: "high",
  context: { tokens: 48213, contextWindow: 200000, percent: 24.1 },
  stats: {
    input: 18342,
    output: 5211,
    cacheRead: 90120,
    cacheWrite: 2048,
    cost: 1.27,
    cacheHitRate: 0.83,
    messages: 42,
    toolCalls: 17,
  },
  cwd: "/home/nazozokc/ghq/github.com/nazozokc/dotfiles",
  branch: "main",
  sessionName: "pi 設定の検証",
  sessionId: "session-abc123",
  sessionStartedAt: Date.now() - 15 * 60 * 1000,
  autoCompact: true,
  providerCount: 3,
  tools: { total: 28, active: 24, mcp: 6, mcpServers: 2 },
  idle: true,
  pending: false,
  activeTool: null,
  recentTools: ["read", "bash", "edit", "grep"],
  statuses: [{ key: "codex-usage", text: "5h 12% · week 30%" }],
} as any;

const getData = () => data;
const getTheme = () => theme;

const components: Record<string, { render(width: number): string[] }> = {
  header: new NazozokcPiHeader(getData, getTheme, home),
  panel: new NazozokcPiPanel(getData, getTheme, home),
  sidebar: new NazozokcPiSidebar(getData, getTheme, home, rows),
  help: new NazozokcPiHelp(
    getData,
    getTheme,
    home,
    [{ name: "/nazozokc-pi", description: "HUD controls" }],
    noop,
    rows,
  ),
  stats: new NazozokcPiStats(getData, getTheme, noop, rows),
  sessions: new NazozokcPiSessions(
    theme,
    noop,
    [
      {
        path: "/home/nazozokc/.local/share/pi/sessions/a.jsonl",
        id: "a",
        cwd: "/home/nazozokc/ghq/github.com/nazozokc/dotfiles",
        name: "設定の検証",
        created: new Date(),
        modified: new Date(),
        messageCount: 12,
        firstMessage: "plan を確認して",
        allMessagesText: "plan を確認して",
      },
    ] as any,
    "/home/nazozokc/.local/share/pi/sessions/a.jsonl",
    home,
    rows,
  ),
};

// Header, panel and sidebar also have a no-data path used during startup.
const emptyComponents = {
  "header-empty": new NazozokcPiHeader(() => null, getTheme, home),
  "panel-empty": new NazozokcPiPanel(() => null, getTheme, home),
  "sidebar-empty": new NazozokcPiSidebar(() => null, getTheme, home, rows),
};

let checks = 0;
for (const [name, component] of Object.entries({
  ...components,
  ...emptyComponents,
})) {
  for (const width of widths) {
    const lines = component.render(width);
    assert.ok(
      Array.isArray(lines),
      `${name}@${width}: render did not return lines`,
    );
    if (!name.endsWith("-empty")) {
      assert.ok(lines.length > 0, `${name}@${width}: render returned no lines`);
    }
    assert.ok(
      lines.length <= 24,
      `${name}@${width}: ${lines.length} lines exceeds terminal rows`,
    );
    for (const line of lines) {
      const actual = visibleWidth(line);
      assert.ok(
        actual <= width,
        `${name}@${width}: line width ${actual} exceeds ${width}`,
      );
    }
    checks += 1;
  }
}

console.log(
  `pi-check: ${checks} render checks passed (${Object.keys(components).length + Object.keys(emptyComponents).length} surfaces)`,
);
