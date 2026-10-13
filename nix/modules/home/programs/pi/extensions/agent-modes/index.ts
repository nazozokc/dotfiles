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
import { registerPlanMode } from "./plan.ts";
import { registerBuildMode } from "./build.ts";
import { registerDangerouslySkipPermissionMode } from "./dangerously-skip-permission.ts";
import { registerExploreMode } from "./explore.ts";
import { registerScoutMode } from "./scout.ts";
import { registerSummaryMode } from "./summary.ts";
import { registerTitleMode } from "./title.ts";

let currentMode: string | null = null;

export default function agentModesExtension(pi: ExtensionAPI): void {
  const setCurrentMode = (mode: string): void => {
    currentMode = mode;
  };

  const getCurrentMode = (): string | null => currentMode;

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

  // Show help on demand
  pi.registerCommand("agent-modes", {
    description:
      "Show available agent modes (plan, build, dangerously-skip-permission, explore, scout, summary, title)",
    handler: async (_args: string, ctx: ExtensionContext) => {
      const modes = [
        "plan - Planning, architecture, design",
        "build - Implementation, bug fixes, coding",
        "dangerously-skip-permission - Skip permission prompts (CAUTION)",
        "explore - Codebase exploration, pattern finding",
        "scout - Quick info gathering",
        "summary - Concise summaries",
        "title - Generate titles",
      ].join("\n");
      ctx.ui.notify(`Available modes:\n${modes}`, "info");
    },
  });
}
