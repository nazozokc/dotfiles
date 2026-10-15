/**
 * git extension — turn checkpoints.
 *
 * Creates a stash commit at the start of every turn that has a dirty work tree,
 * keyed by the transcript entry current at that point. When the user forks the
 * session, index.ts offers to restore the matching checkpoint. Stash objects are
 * dangling commits: harmless, reclaimed by `git gc`.
 *
 * `git stash create` alone only snapshots tracked files, so a turn that merely
 * adds files would yield no checkpoint. To cover untracked files too — without
 * touching the user's index or work tree — the snapshot is taken from a private
 * copy of the index: the copy gets `git add -A` applied, and `git stash create`
 * reads it through `GIT_INDEX_FILE`. `pi.exec` cannot set environment variables,
 * so `env(1)` supplies it. The real index is never modified. Any missing piece
 * (no `env(1)`, e.g. on native Windows) falls back to a plain `stash create`.
 */

import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";

import { git, run } from "./repo.ts";

export interface CheckpointHost {
  /** Stash ref created at the start of the turn that produced `entryId`. */
  get(entryId: string): string | undefined;
}

/** Plain `git stash create` (tracked changes only). */
async function plainStash(pi: ExtensionAPI, cwd: string): Promise<string> {
  const created = await git(pi, ["stash", "create"], cwd);
  return created.code === 0 ? created.stdout.trim() : "";
}

/**
 * Snapshot the work tree — tracked and untracked changes alike — as a stash
 * commit ref. Returns "" when the tree is clean or git cannot be used.
 */
async function createCheckpoint(
  pi: ExtensionAPI,
  cwd: string,
): Promise<string> {
  const located = await git(pi, ["rev-parse", "--absolute-git-dir"], cwd);
  const gitDir = located.stdout.trim();
  if (located.code !== 0 || !gitDir) return plainStash(pi, cwd);

  const stamp = `${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 8)}`;
  const temp = `${gitDir}/pi-checkpoint-${stamp}`;

  const copied = await run(pi, "cp", [`${gitDir}/index`, temp], cwd);
  if (copied.code !== 0) return plainStash(pi, cwd);

  let ref = "";
  try {
    const added = await run(
      pi,
      "env",
      [`GIT_INDEX_FILE=${temp}`, "git", "add", "-A"],
      cwd,
    );
    if (added.code === 0) {
      const created = await run(
        pi,
        "env",
        [`GIT_INDEX_FILE=${temp}`, "git", "stash", "create"],
        cwd,
      );
      if (created.code === 0) ref = created.stdout.trim();
    }
  } finally {
    await run(pi, "rm", ["-f", temp], cwd);
  }

  return ref || plainStash(pi, cwd);
}

export function installCheckpoint(pi: ExtensionAPI): CheckpointHost {
  const checkpoints = new Map<string, string>();
  let currentEntryId: string | undefined;

  // Track the transcript leaf so the next turn's stash can be keyed by it.
  pi.on("tool_result", (_event, ctx) => {
    const leaf = ctx.sessionManager.getLeafEntry();
    if (leaf) currentEntryId = leaf.id;
  });

  pi.on("turn_start", async (_event, ctx) => {
    const status = await git(pi, ["status", "--porcelain"], ctx.cwd);
    if (status.code !== 0 || status.stdout.trim().length === 0) return;
    const ref = await createCheckpoint(pi, ctx.cwd);
    if (ref && currentEntryId) checkpoints.set(currentEntryId, ref);
  });

  pi.on("agent_settled", () => {
    checkpoints.clear();
  });

  return { get: (entryId) => checkpoints.get(entryId) };
}

/**
 * Apply a checkpoint stash back into the work tree.
 *
 * `git restore --source` is used instead of `git stash apply`: apply refuses
 * when any snapshot file has local changes ("would be overwritten"), which is
 * the normal case right after the agent edited those very files. `restore`
 * overwrites the work tree unconditionally and leaves restored files untracked.
 * The `:/` pathspec keeps the restore repo-wide even when pi runs in a
 * subdirectory. Older git without `restore` falls back to `stash apply`.
 */
export async function restoreCheckpoint(
  pi: ExtensionAPI,
  ctx: ExtensionContext,
  ref: string,
): Promise<boolean> {
  const restored = await git(
    pi,
    ["restore", "--source", ref, "--worktree", "--", ":/"],
    ctx.cwd,
  );
  if (restored.code === 0) {
    ctx.ui.notify("Code restored to checkpoint", "info");
    return true;
  }

  const applied = await git(pi, ["stash", "apply", ref], ctx.cwd);
  if (applied.code !== 0) {
    ctx.ui.notify(
      `Checkpoint restore failed: ${applied.stderr.trim() || restored.stderr.trim()}`,
      "error",
    );
    return false;
  }
  ctx.ui.notify("Code restored to checkpoint", "info");
  return true;
}
