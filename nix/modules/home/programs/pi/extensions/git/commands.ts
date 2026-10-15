/**
 * git extension — the `/git` command.
 *
 * One command with subcommands, following the nazozokc-pi `help|stats|...`
 * pattern. Read views (status/log/diff) open an overlay; mutating views
 * (commit/switch/push/pull/stash) run git and report through notifications.
 */

import type {
  ExtensionAPI,
  ExtensionCommandContext,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";

import { operationSummary } from "./operations.ts";
import { combineOutput, git } from "./repo.ts";
import { openGitScreen } from "./screen.ts";
import type { GitState } from "./state.ts";

/** Commits shown by `/git log` when no count is given. */
const LOG_DEFAULT = 20;

function firstLine(text: string): string {
  return text.split("\n")[0]?.trim() ?? "";
}

function helpText(): string {
  return [
    "/git status        working tree status (overlay)",
    "/git log [n]       recent commits (overlay)",
    "/git diff [args]   unstaged changes (overlay)",
    "/git commit [msg]  stage all and commit (opens an editor when msg is omitted)",
    "/git switch <ref>  switch to a branch",
    "/git push [refs]   update remote refs",
    "/git pull          fetch and integrate upstream",
    "/git stash [...]   stash changes (-u includes untracked)",
    "/git autocommit    toggle auto-commit on exit (default off)",
    "",
    "model tool: git(operation, args, message)",
    operationSummary(),
  ].join("\n");
}

export function registerGitCommands(pi: ExtensionAPI, state: GitState): void {
  pi.registerCommand("git", {
    description:
      "Git operations: status|log|diff|commit|switch|push|pull|stash|autocommit",
    handler: async (args, ctx) => {
      const parts = args.trim().split(/\s+/).filter(Boolean);
      const sub = parts.shift() ?? "";
      switch (sub) {
        case "":
        case "help":
          ctx.ui.notify(helpText(), "info");
          return;
        case "status":
          await showStatus(pi, state, ctx);
          return;
        case "log":
          await showLog(pi, ctx, parts);
          return;
        case "diff":
          await showDiff(pi, ctx, parts);
          return;
        case "commit":
          await commit(pi, state, ctx, parts);
          return;
        case "switch":
        case "checkout":
          await switchBranch(pi, state, ctx, parts);
          return;
        case "push":
          await runAndNotify(pi, state, ctx, ["push", ...parts], "push");
          return;
        case "pull":
          await runAndNotify(pi, state, ctx, ["pull", ...parts], "pull");
          return;
        case "stash":
          await runAndNotify(
            pi,
            state,
            ctx,
            ["stash", ...(parts.length > 0 ? parts : ["push"])],
            "stash",
          );
          return;
        case "autocommit":
          toggleAutoCommit(state, ctx);
          return;
        default:
          ctx.ui.notify(
            `Unknown /git subcommand: ${sub}\n\n${helpText()}`,
            "warning",
          );
      }
    },
  });
}

async function showStatus(
  pi: ExtensionAPI,
  state: GitState,
  ctx: ExtensionCommandContext,
): Promise<void> {
  await state.refreshAndShow(ctx);
  const status = state.status;
  if (!status) {
    ctx.ui.notify("Not a git repository", "warning");
    return;
  }
  const porcelain = await git(pi, ["status", "--short"], ctx.cwd);
  const head = status.detached ? `@${status.branch}` : status.branch;
  const lines = [
    `branch   ${head}${status.upstream ? `  → ${status.upstream}` : ""}`,
    `staged ${status.staged}  modified ${status.modified}  untracked ${status.untracked}`,
    status.ahead > 0 || status.behind > 0
      ? `ahead ${status.ahead}  behind ${status.behind}`
      : null,
    "",
    ...(porcelain.stdout.trim()
      ? porcelain.stdout.trimEnd().split("\n")
      : ["(clean)"]),
  ].filter((line): line is string => line !== null);
  openGitScreen(ctx, "git · status", lines);
}

async function showLog(
  pi: ExtensionAPI,
  ctx: ExtensionContext,
  parts: string[],
): Promise<void> {
  const count =
    parts.length > 0 && /^\d+$/.test(parts[0])
      ? parts.shift()!
      : String(LOG_DEFAULT);
  const run = await git(
    pi,
    ["log", "--oneline", "-n", count, ...parts],
    ctx.cwd,
  );
  if (run.code !== 0) {
    ctx.ui.notify(combineOutput(run), "error");
    return;
  }
  openGitScreen(ctx, "git · log", run.stdout.trimEnd().split("\n"));
}

async function showDiff(
  pi: ExtensionAPI,
  ctx: ExtensionContext,
  parts: string[],
): Promise<void> {
  const run = await git(pi, ["diff", ...parts], ctx.cwd);
  if (run.code !== 0) {
    ctx.ui.notify(combineOutput(run), "error");
    return;
  }
  const lines = run.stdout.trim()
    ? run.stdout.trimEnd().split("\n")
    : ["(no changes)"];
  openGitScreen(ctx, "git · diff", lines);
}

async function commit(
  pi: ExtensionAPI,
  state: GitState,
  ctx: ExtensionCommandContext,
  parts: string[],
): Promise<void> {
  let message = parts.join(" ").trim();
  if (!message) {
    message = (await ctx.ui.editor("Commit message", ""))?.trim() ?? "";
  }
  if (!message) {
    ctx.ui.notify("Commit cancelled: empty message", "warning");
    return;
  }
  const add = await git(pi, ["add", "-A"], ctx.cwd);
  if (add.code !== 0) {
    ctx.ui.notify(combineOutput(add), "error");
    return;
  }
  const res = await git(pi, ["commit", "-m", message], ctx.cwd);
  if (res.code !== 0) {
    ctx.ui.notify(combineOutput(res), "error");
  } else {
    ctx.ui.notify(`Committed: ${firstLine(res.stdout) || message}`, "info");
  }
  await state.refreshAndShow(ctx);
}

async function switchBranch(
  pi: ExtensionAPI,
  state: GitState,
  ctx: ExtensionCommandContext,
  parts: string[],
): Promise<void> {
  const ref = parts[0];
  if (!ref) {
    ctx.ui.notify("Usage: /git switch <branch|ref>", "warning");
    return;
  }
  const run = await git(pi, ["switch", ...parts], ctx.cwd);
  if (run.code !== 0) {
    ctx.ui.notify(combineOutput(run), "error");
  } else {
    ctx.ui.notify(`Switched: ${ref}`, "info");
  }
  await state.refreshAndShow(ctx);
}

async function runAndNotify(
  pi: ExtensionAPI,
  state: GitState,
  ctx: ExtensionCommandContext,
  args: string[],
  label: string,
): Promise<void> {
  const run = await git(pi, args, ctx.cwd);
  if (run.code !== 0) {
    ctx.ui.notify(combineOutput(run), "error");
  } else {
    ctx.ui.notify(`${label}: ${firstLine(combineOutput(run)) || "ok"}`, "info");
  }
  await state.refreshAndShow(ctx);
}

function toggleAutoCommit(state: GitState, ctx: ExtensionContext): void {
  state.autoCommit = !state.autoCommit;
  state.show(ctx);
  ctx.ui.notify(
    `auto-commit on exit: ${state.autoCommit ? "ON" : "OFF"}`,
    state.autoCommit ? "warning" : "info",
  );
}
