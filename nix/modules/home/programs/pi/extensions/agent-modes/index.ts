/**
 * Agent modes extension
 *
 * Switches between agent modes with the per-mode commands
 * (/plan, /build, /explore, /scout, /summary, /title, /dangerously-skip-permission)
 * or by cycling with Tab.
 *
 * Activating a mode does four things:
 *   1. stores it as the current mode (reapplied on session start),
 *   2. applies its tool set to the main agent (`setActiveTools`),
 *   3. injects its directive into the system prompt for every turn
 *      (as an <agent_mode> prompt section),
 *   4. shows it persistently in the footer status bar, e.g. "mode:plan".
 *
 * The active mode is also broadcast on the `agent-mode:changed` event bus
 * channel so other extensions (parallel-agents) can make sub-agents follow it.
 *
 * The footer indicator is the source of truth: it is always visible, so the
 * active mode never has to be guessed from a transient notification.
 */
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";

import { planMode } from "./plan.ts";
import { buildMode } from "./build.ts";
import { exploreMode } from "./explore.ts";
import { scoutMode } from "./scout.ts";
import { summaryMode } from "./summary.ts";
import { titleMode } from "./title.ts";
import { dangerouslySkipPermissionMode } from "./dangerously-skip-permission.ts";
import type { AgentMode, ModeConfig } from "./types.ts";
import {
  AGENT_MODE_CHANNEL,
  type AgentModeState,
} from "../shared/agent-mode-bus.ts";

/** Status key. Sorts before "codex-usage", so the mode is never truncated. */
const STATUS_KEY = "agent-mode";
/** System prompt section that carries the active mode directive. */
const SECTION = "agent_mode";

/** Cycle order used by Tab. */
const MODES: readonly ModeConfig[] = [
  planMode,
  buildMode,
  exploreMode,
  scoutMode,
  summaryMode,
  titleMode,
  dangerouslySkipPermissionMode,
];

const MODE_BY_NAME = new Map<string, ModeConfig>(MODES.map((m) => [m.name, m]));

/** `null` until a mode is first selected; shown as "default". */
let currentMode: AgentMode | null = null;

/** Footer label, e.g. "mode:plan". */
function statusText(ctx: ExtensionContext, name: string): string {
  const theme = ctx.ui.theme;
  return `${theme.fg("accent", "mode")}${theme.fg("dim", ":")}${theme.bold(
    theme.fg("text", name),
  )}`;
}

export default function agentModesExtension(pi: ExtensionAPI): void {
  // Apply the mode's tool set to the main agent and broadcast it so that
  // parallel sub-agents can follow the same mode.
  const applyMode = (cfg: ModeConfig): void => {
    pi.setActiveTools(cfg.tools);
    const state: AgentModeState = {
      name: cfg.name,
      prompt: cfg.prompt,
      tools: cfg.tools,
    };
    pi.events.emit(AGENT_MODE_CHANNEL, state);
  };

  const activate = (mode: AgentMode, ctx: ExtensionContext): void => {
    currentMode = mode;
    const cfg = MODE_BY_NAME.get(mode);
    if (!cfg) return;
    applyMode(cfg);
    if (ctx.mode === "tui") {
      ctx.ui.setStatus(STATUS_KEY, statusText(ctx, cfg.name));
    }
    ctx.ui.notify(cfg.notifyMessage, cfg.notifyType ?? "info");
  };

  // Inject the active mode directive into the system prompt for every turn.
  pi.on("before_agent_start", (event) => {
    if (!currentMode) return;
    const cfg = MODE_BY_NAME.get(currentMode);
    if (cfg) event.systemPromptOptions.sections[SECTION] = cfg.prompt;
  });

  // resetExtensionUI() (session switch/fork/new, /reload) clears statuses, so
  // the indicator must be restored on every session start. Apply the mode's
  // tools again too, since the session may have been replaced.
  pi.on("session_start", (_event, ctx) => {
    const cfg = currentMode ? MODE_BY_NAME.get(currentMode) : undefined;
    if (cfg) applyMode(cfg);
    if (ctx.mode === "tui") {
      ctx.ui.setStatus(STATUS_KEY, statusText(ctx, currentMode ?? "default"));
    }
  });

  // One command per mode.
  for (const cfg of MODES) {
    pi.registerCommand(cfg.command, {
      description: cfg.description,
      handler: async (_args, ctx) => activate(cfg.name, ctx),
    });
  }

  // Tab cycles to the next mode. Shift+Tab is left to pi's reserved
  // `app.thinking.cycle` binding (thinking level).
  pi.registerShortcut("tab", {
    description: "Cycle agent mode",
    handler: (ctx) => {
      if (ctx.mode !== "tui") return;
      const idx = currentMode
        ? MODES.findIndex((m) => m.name === currentMode)
        : -1;
      activate(MODES[(idx + 1) % MODES.length].name, ctx);
    },
  });

  pi.registerCommand("agent-modes", {
    description:
      "Show available agent modes (plan, build, dangerously-skip-permission, explore, scout, summary, title)",
    handler: async (_args, ctx) => {
      const list = MODES.map((m) => `${m.command} — ${m.description}`).join(
        "\n",
      );
      ctx.ui.notify(`Available modes (Tab cycles):\n${list}`, "info");
    },
  });
}
