/**
 * Summary mode
 *
 * Summary agent - Concise, accurate summaries.
 */
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import type { ModeConfig } from "./types.ts";

export const summaryMode: ModeConfig = {
  name: "summary",
  command: "summary",
  description: "Switch to summary mode - generate concise, accurate summaries",
  prompt:
    "You are a summarization agent. Focus on concise, accurate summaries of conversations, changes, and context.",
  notifyMessage: "📝 Switched to summary mode",
};

export function registerSummaryMode(
  pi: ExtensionAPI,
  setCurrentMode: (mode: string) => void,
) {
  pi.registerCommand(summaryMode.command, {
    description: summaryMode.description,
    handler: async (_args: string, ctx: ExtensionContext) => {
      setCurrentMode(summaryMode.name);
      ctx.ui.notify(summaryMode.notifyMessage, "info");
    },
  });
}
