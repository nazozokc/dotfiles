/**
 * Build mode
 *
 * Build agent - Focus on implementing features, fixing bugs, and writing code.
 */
import { CODING_TOOLS_PARALLEL, type ModeConfig } from "./types.ts";

export const buildMode: ModeConfig = {
  name: "build",
  command: "build",
  description:
    "Switch to build mode - implement features, fix bugs, write code",
  prompt:
    "You are a build agent. Focus on implementing features, fixing bugs, and writing code. Follow existing patterns and conventions.",
  tools: [...CODING_TOOLS_PARALLEL],
  notifyMessage: "🔨 Switched to build mode",
};
