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

export interface NazozokcPiData {
  model: NazozokcPiModel | null;
  thinkingLevel: string;
  context: NazozokcPiContext;
  stats: NazozokcPiStats;
  cwd: string;
  branch: string | null;
  sessionName: string | null;
  sessionId: string;
  autoCompact: boolean;
  providerCount: number;
  idle: boolean;
  pending: boolean;
  activeTool: NazozokcPiToolCall | null;
  recentTools: string[];
  statuses: NazozokcPiStatus[];
}
