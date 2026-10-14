/**
 * Parallel agents extension agent definitions
 *
 * Custom (repository-owned) sub-agent roles. Tool permissions are not defined
 * here: sub-agents follow the main agent's active agent mode, including its
 * tool set.
 */
import type { ParallelAgentConfig } from "./types.ts";

export const AGENTS: readonly ParallelAgentConfig[] = [
  {
    name: "researcher",
    description:
      "Investigate the codebase and report concise, factual findings",
    prompt:
      "You are a research agent. Investigate the codebase and report concise, factual findings with file references.",
  },
  {
    name: "reviewer",
    description: "Review code for bugs, style issues, and risks",
    prompt:
      "You are a code review agent. Identify bugs, style issues, and risks in the relevant code. Be specific and reference files.",
  },
  {
    name: "tester",
    description: "Run tests and report results",
    prompt:
      "You are a testing agent. Run the relevant tests and report results, including failures and their likely causes.",
  },
  {
    name: "implementer",
    description: "Implement the requested change",
    prompt:
      "You are an implementation agent. Implement the requested change following existing patterns and conventions.",
  },
];

export const AGENT_BY_NAME: ReadonlyMap<string, ParallelAgentConfig> = new Map(
  AGENTS.map((agent) => [agent.name, agent]),
);
