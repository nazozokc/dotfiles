/**
 * Plan mode
 *
 * Planning agent - Focus on architecture, design, and detailed implementation plans.
 */
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
