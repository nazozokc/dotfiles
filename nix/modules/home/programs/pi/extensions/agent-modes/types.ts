/**
 * Agent modes extension types
 */
export type AgentMode =
  | "plan"
  | "build"
  | "dangerously-skip-permission"
  | "explore"
  | "scout"
  | "summary"
  | "title";

export interface ModeConfig {
  name: AgentMode;
  command: string;
  description: string;
  prompt: string;
  notifyMessage: string;
}
