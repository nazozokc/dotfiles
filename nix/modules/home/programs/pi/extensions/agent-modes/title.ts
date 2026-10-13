/**
 * Title mode
 *
 * Title agent - Generate clear, concise titles.
 */
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import type { ModeConfig } from "./types.ts";

export const titleMode: ModeConfig = {
  name: "title",
  command: "title",
  description:
    "Switch to title mode - generate clear, concise titles for sessions and changes",
  prompt:
    "You are a title agent. Focus on generating clear, concise titles for sessions and changes.",
  notifyMessage: "🏷️  Switched to title mode",
};

export function registerTitleMode(
  pi: ExtensionAPI,
  setCurrentMode: (mode: string) => void,
) {
  pi.registerCommand(titleMode.command, {
    description: titleMode.description,
    handler: async (_args: string, ctx: ExtensionContext) => {
      setCurrentMode(titleMode.name);
      ctx.ui.notify(titleMode.notifyMessage, "info");
    },
  });
}
