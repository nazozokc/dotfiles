/**
 * Explore mode
 *
 * Exploration agent - Focus on understanding codebase, finding patterns, gathering context.
 */
import type { ModeConfig } from "./types.ts";

export const exploreMode: ModeConfig = {
  name: "explore",
  command: "explore",
  description:
    "Switch to explore mode - understand codebase, find patterns, gather context",
  prompt:
    "You are an exploration agent. Focus on understanding the codebase, finding patterns, and gathering context.",
  notifyMessage: "🔍 Switched to explore mode",
};
