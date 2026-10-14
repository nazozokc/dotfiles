/**
 * Explore mode
 *
 * Exploration agent - Focus on understanding codebase, finding patterns, gathering context.
 */
import { READ_ONLY_TOOLS_PARALLEL, type ModeConfig } from "./types.ts";

export const exploreMode: ModeConfig = {
  name: "explore",
  command: "explore",
  description:
    "Switch to explore mode - understand codebase, find patterns, gather context",
  prompt:
    "You are an exploration agent. Focus on understanding the codebase, finding patterns, and gathering context.",
  tools: [...READ_ONLY_TOOLS_PARALLEL],
  notifyMessage: "🔍 Switched to explore mode",
};
