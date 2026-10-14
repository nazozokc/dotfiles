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

/** One task in a `parallel` tool call. */
export interface TaskSpec {
  /** Name of a defined agent. */
  agent: string;
  /** Task prompt for the sub-agent. */
  prompt: string;
}

/** Result of one sub-agent run. */
export interface SubAgentResult {
  name: string;
  text: string;
  isError: boolean;
}
