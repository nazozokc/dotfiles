/**
 * Parallel agents extension runner
 *
 * Runs one sub-agent in an isolated, in-memory session:
 *   - inherits the main agent's model,
 *   - follows the active agent mode (prompt + tools) broadcast by agent-modes,
 *   - loads no extensions so the HUD, timers, and the `parallel` tool itself
 *     do not run in the sub-agent (no recursion, no UI side effects).
 */
import {
  createAgentSession,
  DefaultResourceLoader,
  getAgentDir,
  SessionManager,
  type ExtensionContext,
} from "@earendil-works/pi-coding-agent";

import type { AgentModeState } from "../shared/agent-mode-bus.ts";
import type { ParallelAgentConfig, SubAgentResult } from "./types.ts";

type SessionModel = NonNullable<ExtensionContext["model"]>;

export interface RunSubAgentOptions {
  agent: ParallelAgentConfig;
  task: string;
  cwd: string;
  model: SessionModel | undefined;
  mode: AgentModeState | undefined;
  signal?: AbortSignal;
}

export async function runSubAgent(
  options: RunSubAgentOptions,
): Promise<SubAgentResult> {
  const { agent, task, cwd, model, mode, signal } = options;
  const agentDir = getAgentDir();

  const loader = new DefaultResourceLoader({
    cwd,
    agentDir,
    noExtensions: true,
    appendSystemPromptOverride: (base) => [
      ...base,
      ...(mode ? [mode.prompt] : []),
      agent.prompt,
    ],
  });
  await loader.reload();

  const { session } = await createAgentSession({
    cwd,
    agentDir,
    model,
    resourceLoader: loader,
    sessionManager: SessionManager.inMemory(cwd),
    ...(mode ? { tools: mode.tools } : {}),
  });

  const onAbort = (): void => {
    void session.abort();
  };
  signal?.addEventListener("abort", onAbort, { once: true });

  try {
    await session.prompt(task);
    return {
      name: agent.name,
      text: session.getLastAssistantText()?.trim() || "(no output)",
      isError: false,
    };
  } catch (error) {
    return {
      name: agent.name,
      text: error instanceof Error ? error.message : String(error),
      isError: true,
    };
  } finally {
    signal?.removeEventListener("abort", onAbort);
    session.dispose();
  }
}
