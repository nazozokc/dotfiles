/**
 * nazozokc-pi extension — shared data model.
 *
 * A single snapshot is produced by the controller and rendered by the header,
 * panel, status rail, footer and sidebar so every surface stays consistent.
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
  /** contextWindow - tokens, never negative. Null while usage is unknown. */
  remaining: number | null;
  /** Fresh (uncached) tokens spent by the most recent assistant turn. */
  lastTurnTokens: number | null;
  /** Rough turns left at the last turn's burn rate. Null when it cannot be estimated. */
  turnsLeft: number | null;
}

export interface NazozokcPiStats {
  input: number;
  output: number;
  cacheRead: number;
  cacheWrite: number;
  cost: number;
  /** Cost of the most recent assistant turn. */
  turnCost: number;
  /** Fresh (uncached) tokens spent by the most recent assistant turn. */
  lastTurnTokens: number | null;
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

/** Work-tree snapshot for the persistent status rail. */
export interface NazozokcPiGit {
  branch: string;
  detached: boolean;
  dirty: number;
  staged: number;
  untracked: number;
  ahead: number;
  behind: number;
}

/** Host snapshot for the persistent status rail. */
export interface NazozokcPiHost {
  /** One-minute load average, normalized per CPU (load / cpuCount). */
  load: number | null;
  /** Used memory percentage, 0-100. */
  memoryPercent: number | null;
  cpuCount: number;
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
  git: NazozokcPiGit | null;
  host: NazozokcPiHost;
  /** Wall clock sampled per snapshot, so the rail's clock stays live. */
  now: number;
}
