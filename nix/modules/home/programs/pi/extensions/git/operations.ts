/**
 * git extension — tool operation table.
 *
 * The `git` tool exposes a fixed set of operations instead of raw argv so the
 * read/write classification is static and auditable by one table. Read
 * operations run freely; write operations are gated by the tool-confirmation
 * handler (see tool.ts).
 */

/** Parameters accepted by the `git` tool. */
export interface GitToolParams {
  operation: string;
  /** Extra arguments appended after the operation (paths, refs, flags). */
  args?: string[];
  /** Commit message (used by the `commit` operation). */
  message?: string;
}

/** Whether an operation only reads repository state. */
export type OperationKind = "read" | "write";

export interface OperationSpec {
  name: string;
  kind: OperationKind;
  description: string;
  /** Build the git argv for this operation, or return an error string. */
  build(params: GitToolParams): { args: string[] } | { error: string };
}

function extra(params: GitToolParams): string[] {
  return params.args?.filter((arg) => arg.length > 0) ?? [];
}

export const GIT_OPERATIONS: readonly OperationSpec[] = [
  {
    name: "status",
    kind: "read",
    description: "Show the working tree status (short, branch header).",
    build: (params) => ({
      args: ["status", "--short", "--branch", ...extra(params)],
    }),
  },
  {
    name: "diff",
    kind: "read",
    description: "Show changes between commits, the index and the work tree.",
    build: (params) => ({ args: ["diff", ...extra(params)] }),
  },
  {
    name: "log",
    kind: "read",
    description: "Show commit history (oneline, newest first).",
    build: (params) => ({ args: ["log", "--oneline", ...extra(params)] }),
  },
  {
    name: "show",
    kind: "read",
    description: "Show a commit, tag or object (defaults to HEAD).",
    build: (params) => {
      const args = extra(params);
      return { args: ["show", ...(args.length > 0 ? args : ["HEAD"])] };
    },
  },
  {
    name: "branch",
    kind: "read",
    description: "List branches.",
    build: (params) => ({ args: ["branch", ...extra(params)] }),
  },
  {
    name: "add",
    kind: "write",
    description: "Stage paths (stages everything when no paths are given).",
    build: (params) => {
      const args = extra(params);
      return { args: args.length > 0 ? ["add", ...args] : ["add", "-A"] };
    },
  },
  {
    name: "commit",
    kind: "write",
    description: "Record staged changes with a message.",
    build: (params) => {
      const message = params.message?.trim();
      if (!message) return { error: "commit requires a non-empty message" };
      return { args: ["commit", "-m", message] };
    },
  },
  {
    name: "restore",
    kind: "write",
    description: "Restore work tree files (requires paths or --staged).",
    build: (params) => {
      const args = extra(params);
      if (args.length === 0)
        return { error: "restore requires paths or --staged" };
      return { args: ["restore", ...args] };
    },
  },
  {
    name: "switch",
    kind: "write",
    description: "Switch to a branch (requires a ref).",
    build: (params) => {
      const args = extra(params);
      if (args.length === 0)
        return { error: "switch requires a branch or ref" };
      return { args: ["switch", ...args] };
    },
  },
  {
    name: "push",
    kind: "write",
    description: "Update remote refs.",
    build: (params) => ({ args: ["push", ...extra(params)] }),
  },
  {
    name: "pull",
    kind: "write",
    description: "Fetch and integrate with the upstream branch.",
    build: (params) => ({ args: ["pull", ...extra(params)] }),
  },
  {
    name: "stash",
    kind: "write",
    description:
      "Stash changes (defaults to `stash push`; add -u for untracked).",
    build: (params) => {
      const args = extra(params);
      return { args: ["stash", ...(args.length > 0 ? args : ["push"])] };
    },
  },
];

export const OPERATION_BY_NAME: ReadonlyMap<string, OperationSpec> = new Map(
  GIT_OPERATIONS.map((op) => [op.name, op]),
);

/** Operation names in table order. */
export const OPERATION_NAMES: readonly string[] = GIT_OPERATIONS.map(
  (op) => op.name,
);

/** Whether `name` is a known write operation. */
export function isWriteOperation(name: string): boolean {
  return OPERATION_BY_NAME.get(name)?.kind === "write";
}

/** One-line "name — description" list for the help text. */
export function operationSummary(): string {
  return GIT_OPERATIONS.map((op) => {
    const tag = op.kind === "write" ? "write" : "read";
    return `  ${op.name.padEnd(9)} [${tag}] ${op.description}`;
  }).join("\n");
}
