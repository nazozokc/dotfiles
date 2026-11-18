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
}

/** Result of one sub-agent run. */
export interface SubAgentResult {
  name: string;
  text: string;
  isError: boolean;
}
