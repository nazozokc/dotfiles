/**
 * Plan mode
 *
 * Planning agent - Focus on architecture, design, and detailed implementation plans.
 */
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import type { ModeConfig } from "./types.ts";

export const planMode: ModeConfig = {
  name: "plan",
  command: "plan",
  description:
    "Switch to plan mode - architecture, design, and detailed implementation plans",
  prompt:
    "You are a planning agent. Focus on architecture, design, and creating detailed implementation plans. Think before acting.",
  notifyMessage: "📋 Switched to plan mode",
};

export function registerPlanMode(
  pi: ExtensionAPI,
  setCurrentMode: (mode: string) => void,
) {
  pi.registerCommand(planMode.command, {
    description: planMode.description,
    handler: async (_args: string, ctx: ExtensionContext) => {
      setCurrentMode(planMode.name);
      ctx.ui.notify(planMode.notifyMessage, "info");
    },
  });
}
