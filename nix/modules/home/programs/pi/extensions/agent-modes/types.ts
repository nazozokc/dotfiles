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
  /** Transient notification shown when the mode is activated. */
  notifyMessage: string;
  /** Notification severity. Defaults to "info". */
  notifyType?: "info" | "warning" | "error";
}
