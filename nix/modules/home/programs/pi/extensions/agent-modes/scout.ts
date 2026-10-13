/**
 * Scout mode
 *
 * Scout agent - Quick information gathering and answering questions.
 */
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import type { ModeConfig } from "./types.ts";

export const scoutMode: ModeConfig = {
  name: "scout",
  command: "scout",
  description:
    "Switch to scout mode - quick information gathering and answering questions",
  prompt:
    "You are a scout agent. Focus on quick information gathering and answering questions about the codebase.",
  notifyMessage: "🏃 Switched to scout mode",
};

export function registerScoutMode(
  pi: ExtensionAPI,
  setCurrentMode: (mode: string) => void,
) {
  pi.registerCommand(scoutMode.command, {
    description: scoutMode.description,
    handler: async (_args: string, ctx: ExtensionContext) => {
      setCurrentMode(scoutMode.name);
      ctx.ui.notify(scoutMode.notifyMessage, "info");
    },
  });
}
