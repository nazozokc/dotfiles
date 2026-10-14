/**
 * Shared agent-mode event bus contract.
 *
 * Used by the `agent-modes` extension (publisher) and the `parallel-agents`
 * extension (subscriber). Kept in a directory without an `index.ts` so the
 * extension loader does not treat it as an extension entry point.
 */

/** Event bus channel on which the active agent mode is broadcast. */
export const AGENT_MODE_CHANNEL = "agent-mode:changed";

/** Payload broadcast on {@link AGENT_MODE_CHANNEL}. */
export interface AgentModeState {
  name: string;
  /** Directive injected into the system prompt while the mode is active. */
  prompt: string;
  /** Tools enabled while the mode is active. */
  tools: string[];
}
