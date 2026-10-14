/**
 * Agent modes extension types
 */
export type AgentMode =
  | "plan"
  | "build"
  | "explore"
  | "scout"
  | "summary"
  | "title"
  | "dangerously-skip-permission";

export interface ModeConfig {
  name: AgentMode;
  /** Slash command name (without the leading "/"). */
  command: string;
  description: string;
  /** Directive injected into the system prompt while the mode is active. */
  prompt: string;
  /**
   * Tools enabled while the mode is active. Applied to the main agent with
   * `setActiveTools()` and inherited by parallel sub-agents. Names match the
   * built-in tools (read, bash, edit, write, grep, find, ls) plus extension
   * tools (parallel).
   */
  tools: string[];
  /** Transient notification shown when the mode is activated. */
  notifyMessage: string;
  /** Notification severity. Defaults to "info". */
  notifyType?: "info" | "warning" | "error";
}

/** Read-only tool set. */
export const READ_ONLY_TOOLS = ["read", "grep", "find", "ls"] as const;
/** Read-only tools plus the parallel sub-agent tool. */
export const READ_ONLY_TOOLS_PARALLEL = [...READ_ONLY_TOOLS, "parallel"];
/** Full coding tool set plus the parallel sub-agent tool. */
export const CODING_TOOLS_PARALLEL = [
  "read",
  "bash",
  "edit",
  "write",
  "grep",
  "find",
  "ls",
  "parallel",
];
