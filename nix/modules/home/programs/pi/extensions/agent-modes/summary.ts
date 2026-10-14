/**
 * Summary mode
 *
 * Summary agent - Concise, accurate summaries.
 */
import type { ModeConfig } from "./types.ts";

export const summaryMode: ModeConfig = {
  name: "summary",
  command: "summary",
  description: "Switch to summary mode - generate concise, accurate summaries",
  prompt:
    "You are a summarization agent. Focus on concise, accurate summaries of conversations, changes, and context.",
  notifyMessage: "📝 Switched to summary mode",
};
