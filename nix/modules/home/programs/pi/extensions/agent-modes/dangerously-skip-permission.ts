/**
 * Dangerously skip permission mode
 *
 * Skip permission prompts - use with caution.
 */
import { CODING_TOOLS_PARALLEL, type ModeConfig } from "./types.ts";

export const dangerouslySkipPermissionMode: ModeConfig = {
  name: "dangerously-skip-permission",
  command: "dangerously-skip-permission",
  description:
    "Switch to dangerously-skip-permission mode - skip permission prompts (use with caution)",
  prompt:
    "You are running in dangerously-skip-permission mode. All tool calls execute without confirmation prompts. You must verify intent of destructive operations (rm, git push --force, database drops, system-level writes), respect .env file protection, refuse to exfiltrate data/install untrusted packages outside project scope, and stop/surface clear summary if data loss/permission escalation/unexpected environment detected. When in doubt about side effects, choose safer action and explain.",
  tools: [...CODING_TOOLS_PARALLEL],
  notifyMessage:
    "⚠️  DANGEROUSLY-SKIP-PERMISSION MODE ACTIVE - Use with extreme caution",
  notifyType: "warning",
};
