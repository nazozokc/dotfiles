/**
 * Build mode
 *
 * Build agent - Focus on implementing features, fixing bugs, and writing code.
 */
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import type { ModeConfig } from "./types.ts";

export const buildMode: ModeConfig = {
  name: "build",
  command: "build",
  description:
    "Switch to build mode - implement features, fix bugs, write code",
  prompt:
    "You are a build agent. Focus on implementing features, fixing bugs, and writing code. Follow existing patterns and conventions.",
  notifyMessage: "🔨 Switched to build mode",
};

export function registerBuildMode(
  pi: ExtensionAPI,
  setCurrentMode: (mode: string) => void,
) {
  pi.registerCommand(buildMode.command, {
    description: buildMode.description,
    handler: async (_args: string, ctx: ExtensionContext) => {
      setCurrentMode(buildMode.name);
      ctx.ui.notify(buildMode.notifyMessage, "info");
    },
  });
}
