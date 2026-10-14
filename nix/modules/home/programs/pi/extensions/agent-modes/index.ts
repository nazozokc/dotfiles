/**
 * Agent modes extension
 *
 * Provides commands to switch between agent modes:
 *   /plan, /build, /dangerously-skip-permission, /explore, /scout, /summary, /title
 *
 * Registers these commands for easy mode switching. Mode state is tracked
 * and reapplied on session start.
 */
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import type { KeyId } from "@earendil-works/pi-tui";
import { registerPlanMode } from "./plan.ts";
import { registerBuildMode } from "./build.ts";
import { registerDangerouslySkipPermissionMode } from "./dangerously-skip-permission.ts";
import { registerExploreMode } from "./explore.ts";
import { registerScoutMode } from "./scout.ts";
import { registerSummaryMode } from "./summary.ts";
import { registerTitleMode } from "./title.ts";

let currentMode: string | null = null;

const modes = [
  "plan",
  "build",
  "explore",
  "scout",
  "summary",
  "title",
  "dangerously-skip-permission",
] as const;

export default function agentModesExtension(pi: ExtensionAPI): void {
  const setCurrentMode = (mode: string): void => {
    currentMode = mode;
  };

  const getCurrentMode = (): string | null => currentMode;

  const cycleMode = (dir: "next" | "prev", ctx: ExtensionContext): void => {
    if (modes.length === 0) return;
    const idx = currentMode ? modes.indexOf(currentMode as (typeof modes)[number]) : -1;
    const nextIdx =
      dir === "next"
        ? (idx + 1 + modes.length) % modes.length
        : (idx - 1 + modes.length) % modes.length;
    const mode = modes[nextIdx];
    void (pi as any).executeCommand?.(mode, "");
  };

  // Register all mode commands
  registerPlanMode(pi, setCurrentMode);
  registerBuildMode(pi, setCurrentMode);
  registerDangerouslySkipPermissionMode(pi, setCurrentMode);
  registerExploreMode(pi, setCurrentMode);
  registerScoutMode(pi, setCurrentMode);
  registerSummaryMode(pi, setCurrentMode);
  registerTitleMode(pi, setCurrentMode);

  // Show current mode on session start
  pi.on("session_start", (_event, ctx: ExtensionContext) => {
    if (ctx.mode !== "tui") return;
    if (currentMode) {
      ctx.ui.notify(`Active agent mode: ${currentMode}`, "info");
    }
  });

  // Cycle modes with Tab / Shift+Tab in TUI
  const registerTuiShortcut = (
    key: KeyId,
    description: string,
    handler: (ctx: ExtensionContext) => void,
  ): void => {
    pi.registerShortcut(key, {
      description,
      handler: (ctx) => {
        if (ctx.mode !== "tui") return;
        handler(ctx);
      },
    });
  };

  registerTuiShortcut("tab", "Cycle agent mode (next)", (ctx) => cycleMode("next", ctx));
  registerTuiShortcut("shift+tab", "Cycle agent mode (prev)", (ctx) =>
    cycleMode("prev", ctx),
  );

  // Show help on demand
  pi.registerCommand("agent-modes", {
    description:
      "Show available agent modes (plan, build, dangerously-skip-permission, explore, scout, summary, title)",
    handler: async (_args: string, ctx: ExtensionContext) => {
      const modesList = [
        "plan - Planning, architecture, design",
        "build - Implementation, bug fixes, coding",
        "dangerously-skip-permission - Skip permission prompts (CAUTION)",
        "explore - Codebase exploration, pattern finding",
        "scout - Quick info gathering",
        "summary - Concise summaries",
        "title - Generate titles",
      ].join("\n");
      ctx.ui.notify(`Available modes:\n${modesList}`, "info");
    },
  });
}
