/**
 * Plan mode
 *
 * Planning agent - Focus on architecture, design, and detailed implementation plans.
 */
import { READ_ONLY_TOOLS_PARALLEL, type ModeConfig } from "./types.ts";

export const planMode: ModeConfig = {
  name: "plan",
  command: "plan",
  description:
    "Switch to plan mode - architecture, design, and detailed implementation plans",
  prompt:
    "You are a planning agent. Focus on architecture, design, and creating detailed implementation plans. Think before acting.",
  tools: [...READ_ONLY_TOOLS_PARALLEL],
  confirm: false,
  notifyMessage: "📋 Switched to plan mode",
};
