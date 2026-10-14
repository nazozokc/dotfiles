/**
 * Scout mode
 *
 * Scout agent - Quick information gathering and answering questions.
 */
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
