/**
 * Parallel agents extension
 *
 * Registers a `parallel` tool the model can call when it judges that a task
 * splits into independent subtasks. Each subtask runs as a sub-agent in an
 * isolated in-memory session that inherits the main agent's model and follows
 * the active agent mode (prompt + tool set) broadcast by the `agent-modes`
 * extension on the shared event bus.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { defineTool } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

import { AGENT_BY_NAME, AGENTS } from "./agents.ts";
import { runSubAgent } from "./runner.ts";
import {
  AGENT_MODE_CHANNEL,
  type AgentModeState,
} from "../shared/agent-mode-bus.ts";

/** Upper bound on concurrently spawned sub-agents. */
const MAX_TASKS = 8;

export default function parallelAgentsExtension(pi: ExtensionAPI): void {
  /** Latest agent mode broadcast by the agent-modes extension. */
  let mode: AgentModeState | undefined;

  pi.events.on(AGENT_MODE_CHANNEL, (data) => {
    mode = data as AgentModeState;
  });

  const agentNames = AGENTS.map((agent) => agent.name).join(", ");

  pi.registerTool(
    defineTool({
      name: "parallel",
      label: "Parallel Agents",
      description:
        "Run multiple sub-agents concurrently and collect their results. " +
        `Available agents: ${agentNames}.`,
      promptSnippet: "Run several independent sub-agents in parallel",
      promptGuidelines: [
        "Use the parallel tool when a task splits into independent subtasks that can run concurrently.",
        `Each task names an agent (${agentNames}) and a prompt.`,
      ],
      parameters: Type.Object({
        tasks: Type.Array(
          Type.Object({
            agent: Type.String({
              description: `Agent name. One of: ${agentNames}`,
            }),
            prompt: Type.String({ description: "Task for the sub-agent" }),
          }),
          { minItems: 1, maxItems: MAX_TASKS },
        ),
      }),
      async execute(_toolCallId, params, signal, _onUpdate, ctx) {
        const results = await Promise.all(
          params.tasks.map((task) => {
            const agent = AGENT_BY_NAME.get(task.agent);
            if (!agent) {
              return Promise.resolve({
                name: task.agent,
                text: `Unknown agent: ${task.agent}. Available: ${agentNames}`,
                isError: true,
              });
            }
            return runSubAgent({
              agent,
              task: task.prompt,
              cwd: ctx.cwd,
              model: ctx.model,
              mode,
              signal,
            });
          }),
        );

        const text = results.map((r) => `## ${r.name}\n${r.text}`).join("\n\n");

        return {
          content: [{ type: "text", text }],
          details: { results },
          isError: results.every((r) => r.isError),
        };
      },
    }),
  );
}
