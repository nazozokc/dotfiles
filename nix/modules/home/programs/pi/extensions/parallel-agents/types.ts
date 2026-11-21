/**
 * Parallel agents extension types
 */

/** A sub-agent the `parallel` tool can dispatch a task to. */
export interface ParallelAgentConfig {
  /** Agent name used in `parallel` task specs. */
  name: string;
  /** Short description shown in tool listings. */
  description: string;
  /** Role directive appended to the sub-agent's system prompt. */
  prompt: string;
  /**
   * Optional tool allowlist for this role. Intersected with the active agent
   * mode's tools so sub-agents never gain tools the mode has disabled.
   * Omit to inherit the mode's tool set as-is.
   */
  tools?: string[];
}

/** Result of one sub-agent run. */
export interface SubAgentResult {
  name: string;
  text: string;
  isError: boolean;
}
