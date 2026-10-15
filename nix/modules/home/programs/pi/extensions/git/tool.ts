/**
 * git extension — the model-callable `git` tool.
 *
 * Exposes a fixed set of read/write operations (see operations.ts) as one tool.
 * Read operations run without prompting. Write operations ask the user for
 * approval first: that confirmation lives here, not in agent-modes, so a git
 * write is gated even when the active mode disabled its own dialog.
 */

import type {
  ExtensionAPI,
  ToolCallEventResult,
} from "@earendil-works/pi-coding-agent";
import { defineTool } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

import {
  OPERATION_NAMES,
  OPERATION_BY_NAME,
  isWriteOperation,
  operationSummary,
} from "./operations.ts";
import { combineOutput, git } from "./repo.ts";

/** Longest argument preview rendered in the approval dialog. */
const PREVIEW_LIMIT = 200;

/** Build the dialog message for a write operation. */
function previewCall(input: Record<string, unknown>): string {
  const args = Array.isArray(input.args) ? (input.args as unknown[]) : [];
  const message = typeof input.message === "string" ? input.message : undefined;
  const parts = [
    `operation: ${String(input.operation ?? "")}`,
    args.length > 0 ? `args: ${args.map(String).join(" ")}` : undefined,
    message ? `message: ${message}` : undefined,
  ].filter((part): part is string => part !== undefined);
  const text = parts.join("\n");
  return text.length > PREVIEW_LIMIT
    ? `${text.slice(0, PREVIEW_LIMIT)}…`
    : text;
}

export function registerGitTool(pi: ExtensionAPI): void {
  pi.registerTool(
    defineTool({
      name: "git",
      label: "Git",
      description:
        "Run a git operation in the current repository. " +
        "Read operations inspect state; write operations change the repository " +
        "and require user approval.\n" +
        operationSummary(),
      promptSnippet: "Run read/write git operations",
      promptGuidelines: [
        "Use the git tool for git work instead of the bash tool so operations are classified and gated.",
        "Prefer read operations (status, diff, log, show, branch) to inspect the repository before changing it.",
        "Write operations (add, commit, restore, switch, push, pull, stash) ask the user for approval before running.",
        "Pass `args` for paths/refs/flags and `message` for commit.",
      ],
      parameters: Type.Object({
        operation: Type.Union(
          OPERATION_NAMES.map((name) => Type.Literal(name)),
          { description: "Git operation to run." },
        ),
        args: Type.Optional(
          Type.Array(Type.String(), {
            description:
              "Extra arguments (paths, refs, flags) for the operation.",
          }),
        ),
        message: Type.Optional(
          Type.String({
            description: "Commit message (commit operation only).",
          }),
        ),
      }),
      async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
        const spec = OPERATION_BY_NAME.get(params.operation);
        if (!spec) {
          return {
            content: [
              {
                type: "text",
                text: `Unknown git operation: ${params.operation}`,
              },
            ],
            details: { args: [], code: 1 },
            isError: true,
          };
        }
        const built = spec.build(params);
        if ("error" in built) {
          return {
            content: [{ type: "text", text: built.error }],
            details: { args: [], code: 1 },
            isError: true,
          };
        }
        const run = await git(pi, built.args, ctx.cwd);
        return {
          content: [{ type: "text", text: combineOutput(run) }],
          details: { args: run.args, code: run.code },
          isError: run.code !== 0,
        };
      },
    }),
  );

  // Approve git write operations. Independent of agent-modes: this dialog owns
  // the "git" tool, so it fires regardless of the active mode's confirm flag.
  pi.on(
    "tool_call",
    async (event, ctx): Promise<ToolCallEventResult | undefined> => {
      if (event.toolName !== "git") return;
      if (!ctx.hasUI) return;
      const operation =
        typeof event.input.operation === "string" ? event.input.operation : "";
      if (!isWriteOperation(operation)) return;

      const approved = await ctx.ui.confirm(
        `Allow git ${operation}?`,
        previewCall(event.input),
      );
      if (approved) return;
      return {
        block: true,
        reason: `git ${operation} was declined by the user`,
      };
    },
  );
}
