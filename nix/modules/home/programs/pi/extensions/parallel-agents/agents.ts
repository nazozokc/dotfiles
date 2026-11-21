/**
 * Parallel agents extension agent definitions
 *
 * Custom (repository-owned) sub-agent roles. Role names, descriptions and
 * prompts mirror nix/lib/agent-roles.nix; agents-doctor checks for drift.
 *
 * `tools` is a role-level ceiling. It is intersected with the active agent
 * mode's tool set, so a read-only role stays read-only even when the main
 * agent is in build mode. No role includes `parallel` — sub-agents cannot
 * spawn further sub-agents.
 */
import type { ParallelAgentConfig } from "./types.ts";

/** Built-in read-only tools (no git, no parallel). */
const READ_ONLY = ["read", "grep", "find", "ls"];

export const AGENTS: readonly ParallelAgentConfig[] = [
  {
    name: "plan",
    description: "Architecture, design, and detailed implementation plans",
    prompt:
      "You are a planning agent. Focus on architecture, design, and creating detailed implementation plans. Think before acting.",
    tools: [...READ_ONLY],
  },
  {
    name: "scout",
    description: "Quick read-only information gathering and codebase questions",
    prompt:
      "You are a scout agent. Focus on quick information gathering and answering questions about the codebase.",
    tools: [...READ_ONLY],
  },
  {
    name: "explore",
    description: "Read-only codebase exploration: patterns, structure, context",
    prompt:
      "You are an exploration agent. Focus on understanding the codebase, finding patterns, and gathering context.",
    tools: [...READ_ONLY],
  },
  {
    name: "review",
    description:
      "Review current changes for correctness, security, and maintainability",
    prompt:
      "You are a code review agent. Review the current changes for correctness, security, and maintainability. Report concrete findings with file:line references and severity. Do not modify files.",
    tools: [...READ_ONLY, "git"],
  },
  {
    name: "test",
    description:
      "Write or update focused tests and run the relevant test commands",
    prompt:
      "You are a test agent. Write or update focused tests for the current changes, run the relevant test commands, and report failures and coverage gaps.",
    tools: [...READ_ONLY, "bash"],
  },
  {
    name: "build",
    description:
      "Implement features, fix bugs, write code following existing patterns",
    prompt:
      "You are a build agent. Focus on implementing features, fixing bugs, and writing code. Follow existing patterns and conventions.",
    tools: [...READ_ONLY, "bash", "edit", "write", "git"],
  },
];

export const AGENT_BY_NAME: ReadonlyMap<string, ParallelAgentConfig> = new Map(
  AGENTS.map((agent) => [agent.name, agent]),
);
