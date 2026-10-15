/**
 * git extension — repository helpers.
 *
 * Thin wrapper over `pi.exec("git", ...)` and a parser for `git status` so the
 * rest of the extension can reason about the work tree (branch, dirty counts,
 * upstream divergence) without re-implementing porcelain parsing.
 */

import type {
  ExtensionAPI,
  ExecOptions,
  ExecResult,
} from "@earendil-works/pi-coding-agent";

/** Result of a git invocation (stdout/stderr already decoded). */
export interface GitRun {
  args: string[];
  stdout: string;
  stderr: string;
  code: number;
}

/** Run `command <args>` in `cwd`. */
export async function run(
  pi: ExtensionAPI,
  command: string,
  args: string[],
  cwd: string,
  options?: ExecOptions,
): Promise<GitRun> {
  const result: ExecResult = await pi.exec(command, args, { cwd, ...options });
  return {
    args,
    stdout: result.stdout,
    stderr: result.stderr,
    code: result.code,
  };
}

/** Run `git <args>` in `cwd`. */
export function git(
  pi: ExtensionAPI,
  args: string[],
  cwd: string,
  options?: ExecOptions,
): Promise<GitRun> {
  return run(pi, "git", args, cwd, options);
}

/** Whether `cwd` is inside a git work tree. */
export async function isRepo(pi: ExtensionAPI, cwd: string): Promise<boolean> {
  const { code } = await git(pi, ["rev-parse", "--is-inside-work-tree"], cwd);
  return code === 0;
}

/** Snapshot of the work tree used by the footer, guard and status screen. */
export interface RepoStatus {
  branch: string;
  detached: boolean;
  staged: number;
  modified: number;
  untracked: number;
  /** staged + modified + untracked */
  dirty: number;
  upstream: string | null;
  ahead: number;
  behind: number;
}

/** Parse `git status --porcelain` plus branch/upstream metadata. */
export async function readStatus(
  pi: ExtensionAPI,
  cwd: string,
): Promise<RepoStatus | null> {
  const status = await git(pi, ["status", "--porcelain"], cwd);
  if (status.code !== 0) return null;

  let staged = 0;
  let modified = 0;
  let untracked = 0;
  for (const line of status.stdout.split("\n")) {
    if (!line) continue;
    const x = line[0];
    const y = line[1];
    if (x === "?" && y === "?") {
      untracked++;
      continue;
    }
    if (x !== " " && x !== "?") staged++;
    if (y !== " " && y !== "?") modified++;
  }

  const headName = await git(pi, ["rev-parse", "--abbrev-ref", "HEAD"], cwd);
  const rawBranch = headName.code === 0 ? headName.stdout.trim() : "";
  let branch = rawBranch;
  let detached = false;
  if (!rawBranch || rawBranch === "HEAD") {
    detached = true;
    const sha = await git(pi, ["rev-parse", "--short", "HEAD"], cwd);
    branch = sha.code === 0 ? sha.stdout.trim() : "(no commits)";
  }

  let upstream: string | null = null;
  let ahead = 0;
  let behind = 0;
  const up = await git(
    pi,
    ["rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}"],
    cwd,
  );
  if (up.code === 0 && up.stdout.trim()) {
    upstream = up.stdout.trim();
    const counts = await git(
      pi,
      ["rev-list", "--left-right", "--count", "@{u}...HEAD"],
      cwd,
    );
    if (counts.code === 0) {
      const [behindRaw, aheadRaw] = counts.stdout.trim().split(/\s+/);
      behind = Number(behindRaw) || 0;
      ahead = Number(aheadRaw) || 0;
    }
  }

  return {
    branch,
    detached,
    staged,
    modified,
    untracked,
    dirty: staged + modified + untracked,
    upstream,
    ahead,
    behind,
  };
}

/** Combine a run's stdout and stderr into one trimmed block. */
export function combineOutput(run: GitRun): string {
  const text = [run.stdout.trimEnd(), run.stderr.trimEnd()]
    .filter((part) => part.length > 0)
    .join("\n");
  return text.length > 0
    ? text
    : `(git ${run.args.join(" ")} exited ${run.code})`;
}
