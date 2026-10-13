/**
 * nazozokc-pi extension — shared data model.
 *
 * A single snapshot is produced by the controller and rendered by the header,
 * panel, footer and sidebar so every surface stays consistent.
 */

export interface NazozokcPiModel {
  id: string;
  name: string;
  provider: string;
  reasoning: boolean;
  contextWindow: number;
  /** Maximum output tokens the model may generate in one response. */
  maxTokens: number;
}

export interface NazozokcPiContext {
  tokens: number | null;
  contextWindow: number;
  percent: number | null;
}

export interface NazozokcPiStats {
  input: number;
  output: number;
  cacheRead: number;
  cacheWrite: number;
  cost: number;
  cacheHitRate: number | null;
  messages: number;
  toolCalls: number;
}

export interface NazozokcPiToolCall {
  name: string;
  startedAt: number;
}

export interface NazozokcPiStatus {
  key: string;
  text: string;
}

export interface NazozokcPiTools {
  /** Every registered tool. */
  total: number;
  /** Registered tools declared to the model right now. */
  active: number;
  /** Tools exposed by MCP servers. */
  mcp: number;
  /** Connected MCP servers (derived from tool namespaces). */
  mcpServers: number;
}

export interface NazozokcPiData {
  model: NazozokcPiModel | null;
  thinkingLevel: string;
  context: NazozokcPiContext;
  stats: NazozokcPiStats;
  cwd: string;
  branch: string | null;
  sessionName: string | null;
  sessionId: string;
  /** Session start time (epoch ms) from the session header, or null if unknown. */
  sessionStartedAt: number | null;
  autoCompact: boolean;
  providerCount: number;
  tools: NazozokcPiTools;
  idle: boolean;
  pending: boolean;
  activeTool: NazozokcPiToolCall | null;
  recentTools: string[];
  statuses: NazozokcPiStatus[];
}
