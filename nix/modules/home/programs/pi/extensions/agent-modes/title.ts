/**
 * Title mode
 *
 * Title agent - Generate clear, concise titles.
 */
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
