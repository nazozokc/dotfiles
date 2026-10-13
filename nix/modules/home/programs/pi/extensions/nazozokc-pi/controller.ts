/**
 * nazozokc-pi extension — state controller.
 *
 * Owns the live snapshot consumed by every nazozokc-pi surface (header, panel, footer,
 * sidebar). Event handlers mutate cheap dynamic state, while token/cost totals
 * are recomputed from the session branch and memoized by branch position so
 * renders stay cheap.
 */

import type { AssistantMessage } from "@earendil-works/pi-ai";
import type {
  ExtensionAPI,
  ExtensionContext,
  ReadonlyFooterDataProvider,
} from "@earendil-works/pi-coding-agent";
import type { SessionEntry } from "@earendil-works/pi-coding-agent";
import type { TUI } from "@earendil-works/pi-tui";

import type {
  NazozokcPiContext,
  NazozokcPiData,
  NazozokcPiStats,
  NazozokcPiStatus,
  NazozokcPiToolCall,
  NazozokcPiTools,
} from "./types.ts";

const RECENT_TOOL_LIMIT = 8;

/** Tools whose results are not counted as a normal tool call. */
const HIDDEN_FROM_RECENT = new Set<string>();

export class NazozokcPiController {
  private readonly pi: ExtensionAPI;
  private readonly home: string | undefined;

  private footerData: ReadonlyFooterDataProvider | null = null;
  private tui: TUI | null = null;

  private readonly activeTools = new Map<string, NazozokcPiToolCall>();
  private recentTools: string[] = [];

  private memoKey = "";
  private memoStats: NazozokcPiStats | null = null;
  private memoContext: NazozokcPiContext | null = null;

  constructor(pi: ExtensionAPI, home: string | undefined) {
    this.pi = pi;
    this.home = home;
  }

  /** Wire the live TUI (from the first component factory). */
  attachTui(tui: TUI): void {
    this.tui = tui;
  }

  /**
   * Wire the footer data provider. Only the footer factory receives it, so
   * `setFooter` must be installed before any surface renders.
   */
  attachFooterData(footerData: ReadonlyFooterDataProvider): void {
    this.footerData = footerData;
  }

  getHome(): string | undefined {
    return this.home;
  }

  requestRender(): void {
    this.tui?.requestRender();
  }

  /** Live terminal height in rows, or undefined when the TUI is not attached. */
  getTerminalRows(): number | undefined {
    return this.tui?.terminal?.rows;
  }

  // --- event handlers ------------------------------------------------------

  onToolStart(toolCallId: string, toolName: string): void {
    this.activeTools.set(toolCallId, { name: toolName, startedAt: Date.now() });
    this.requestRender();
  }

  onToolEnd(toolCallId: string, toolName: string): void {
    this.activeTools.delete(toolCallId);
    if (!HIDDEN_FROM_RECENT.has(toolName)) {
      this.recentTools = [
        toolName,
        ...this.recentTools.filter((t) => t !== toolName),
      ];
      if (this.recentTools.length > RECENT_TOOL_LIMIT) {
        this.recentTools = this.recentTools.slice(0, RECENT_TOOL_LIMIT);
      }
    }
    this.requestRender();
  }

  onBoundary(): void {
    this.requestRender();
  }

  /** Reset transient tool activity (e.g. on a new session). */
  reset(): void {
    this.activeTools.clear();
    this.recentTools = [];
    this.memoKey = "";
    this.memoStats = null;
    this.memoContext = null;
  }

  // --- snapshot ------------------------------------------------------------

  getData(ctx: ExtensionContext): NazozokcPiData {
    const model = ctx.model;
    const thinkingLevel = ctx.thinkingLevel ?? this.pi.getThinkingLevel();
    const { stats, context } = this.getSnapshot(ctx);

    const statuses: NazozokcPiStatus[] = [];
    for (const [key, text] of this.footerData?.getExtensionStatuses() ?? []) {
      if (text) statuses.push({ key, text });
    }

    const header = ctx.sessionManager.getHeader();
    const started = header ? Date.parse(header.timestamp) : Number.NaN;

    return {
      model: model
        ? {
            id: model.id,
            name: model.name,
            provider: model.provider,
            reasoning: model.reasoning,
            contextWindow: model.contextWindow,
            maxTokens: model.maxTokens,
          }
        : null,
      thinkingLevel,
      context,
      stats,
      cwd: ctx.cwd,
      branch: this.footerData?.getGitBranch() ?? null,
      sessionName: ctx.sessionManager.getSessionName() ?? null,
      sessionId: ctx.sessionManager.getSessionId(),
      sessionStartedAt: Number.isNaN(started) ? null : started,
      autoCompact: this.pi.getSettings().compaction?.enabled ?? true,
      providerCount: this.footerData?.getAvailableProviderCount() ?? 0,
      tools: this.getToolStats(),
      idle: ctx.isIdle(),
      pending: ctx.hasPendingMessages(),
      activeTool: this.getActiveTool(),
      recentTools: [...this.recentTools],
      statuses,
    };
  }

  /**
   * Tool inventory: how many tools are registered/active, and how many come
   * from MCP servers. MCP tools are named `mcp__<server>__<tool>`, so the
   * server set is derived from tool names (and namespaces when present).
   */
  private getToolStats(): NazozokcPiTools {
    const all = this.pi.getAllTools();
    const activeNames = new Set(this.pi.getActiveTools());
    let mcp = 0;
    let active = 0;
    const servers = new Set<string>();
    for (const tool of all) {
      if (activeNames.has(tool.name)) active += 1;
      const namespace = tool.namespace?.name;
      const isMcp =
        tool.name.startsWith("mcp__") || !!namespace?.startsWith("mcp__");
      if (!isMcp) continue;
      mcp += 1;
      const server = namespace?.startsWith("mcp__")
        ? namespace
        : `mcp__${tool.name.split("__")[1] ?? ""}`;
      if (server !== "mcp__") servers.add(server);
    }
    return { total: all.length, active, mcp, mcpServers: servers.size };
  }

  private getActiveTool(): NazozokcPiToolCall | null {
    let latest: NazozokcPiToolCall | null = null;
    for (const call of this.activeTools.values()) {
      if (!latest || call.startedAt > latest.startedAt) latest = call;
    }
    return latest;
  }

  /**
   * Token/cost totals and context usage both scan the session, and the panel
   * renders every frame. Cache them by session position and model: entries are
   * append-only and every append moves the leaf, so the key changes whenever
   * the data can.
   */
  private getSnapshot(ctx: ExtensionContext): {
    stats: NazozokcPiStats;
    context: NazozokcPiContext;
  } {
    const session = ctx.sessionManager;
    const modelId = ctx.model?.id ?? "-";
    const key = `${session.getSessionId()}:${session.getLeafId() ?? "-"}:${modelId}`;
    if (key === this.memoKey && this.memoStats && this.memoContext) {
      return { stats: this.memoStats, context: this.memoContext };
    }
    const stats = computeStats(session.getEntries());
    const usage = ctx.getContextUsage();
    const context: NazozokcPiContext = {
      tokens: usage?.tokens ?? null,
      contextWindow: usage?.contextWindow ?? ctx.model?.contextWindow ?? 0,
      percent: usage?.percent ?? null,
    };
    this.memoKey = key;
    this.memoStats = stats;
    this.memoContext = context;
    return { stats, context };
  }
}

/**
 * Aggregate token/cost totals exactly like Pi's built-in footer: assistant
 * messages, tool results, compaction/branch summaries and usage entries all
 * contribute, and the cache-hit rate reflects the latest assistant response.
 */
export function computeStats(entries: SessionEntry[]): NazozokcPiStats {
  let input = 0;
  let output = 0;
  let cacheRead = 0;
  let cacheWrite = 0;
  let cost = 0;
  let messages = 0;
  let toolCalls = 0;
  let cacheHitRate: number | null = null;

  const addUsage = (usage: {
    input: number;
    output: number;
    cacheRead: number;
    cacheWrite: number;
    cost: { total: number };
  }): void => {
    input += usage.input;
    output += usage.output;
    cacheRead += usage.cacheRead;
    cacheWrite += usage.cacheWrite;
    cost += usage.cost.total;
  };

  for (const entry of entries) {
    switch (entry.type) {
      case "message": {
        const message = entry.message;
        if (message.role === "assistant") {
          messages += 1;
          const assistant = message as AssistantMessage;
          addUsage(assistant.usage);
          const promptTokens =
            assistant.usage.input +
            assistant.usage.cacheRead +
            assistant.usage.cacheWrite;
          cacheHitRate =
            promptTokens > 0
              ? (assistant.usage.cacheRead / promptTokens) * 100
              : cacheHitRate;
          for (const block of assistant.content) {
            if (block.type === "toolCall") toolCalls += 1;
          }
        } else if (message.role === "toolResult" && message.usage) {
          addUsage(message.usage);
        }
        break;
      }
      case "compaction":
      case "branch_summary":
        if (entry.usage) addUsage(entry.usage);
        break;
      case "usage":
        addUsage(entry.usage);
        break;
      default:
        break;
    }
  }

  return {
    input,
    output,
    cacheRead,
    cacheWrite,
    cost,
    cacheHitRate,
    messages,
    toolCalls,
  };
}
