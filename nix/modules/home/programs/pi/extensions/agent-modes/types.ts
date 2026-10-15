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
  /**
   * Whether this mode asks the user to approve each mutating tool call
   * (anything outside the read-only set) before it runs. Read-only tools are
   * never confirmed, so this only matters for modes that can also run bash,
   * edit, write, parallel sub-agents, or custom/MCP tools.
   */
  confirm: boolean;
  /** Transient notification shown when the mode is activated. */
  notifyMessage: string;
  /** Notification severity. Defaults to "info". */
  notifyType?: "info" | "warning" | "error";
}

/** Read-only tool set. */
export const READ_ONLY_TOOLS = ["read", "grep", "find", "ls"] as const;
/**
 * Read-only tools plus the extension tools that stay available in every mode:
 * the parallel sub-agent tool and the git tool. Git writes are gated by the git
 * extension's own approval dialog, so the tool is safe to keep active even in
 * read-only modes.
 */
export const READ_ONLY_TOOLS_PARALLEL = [...READ_ONLY_TOOLS, "parallel", "git"];
/** Full coding tool set plus the parallel sub-agent and git tools. */
export const CODING_TOOLS_PARALLEL = [
  "read",
  "bash",
  "edit",
  "write",
  "grep",
  "find",
  "ls",
  "parallel",
  "git",
];
