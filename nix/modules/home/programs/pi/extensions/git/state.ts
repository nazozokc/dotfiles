/**
 * git extension — shared state.
 *
 * Holds the current repository status and the auto-commit toggle, and renders
 * the footer indicator. The footer factory in nazozokc-pi draws every extension
 * status set via `ctx.ui.setStatus()`, so this is how the branch / dirty marker
 * / auto-commit flag reach the status bar without touching that extension.
 */

import type {
  ExtensionAPI,
  ExtensionContext,
  Theme,
} from "@earendil-works/pi-coding-agent";

import { readStatus, type RepoStatus } from "./repo.ts";

/** Footer status key (sorts after "agent-mode" and "codex-usage"). */
export const STATUS_KEY = "git";

export class GitState {
  /** Whether the session auto-commits uncommitted changes on shutdown. */
  autoCommit = false;
  /** Last read work-tree status, or null when not in a repository. */
  status: RepoStatus | null = null;

  constructor(private readonly pi: ExtensionAPI) {}

  /** Re-read the work-tree status. Returns null when not in a repository. */
  async refresh(ctx: ExtensionContext): Promise<RepoStatus | null> {
    this.status = await readStatus(this.pi, ctx.cwd);
    return this.status;
  }

  /** Refresh and repaint the footer indicator. */
  async refreshAndShow(ctx: ExtensionContext): Promise<void> {
    await this.refresh(ctx);
    this.show(ctx);
  }

  /** Paint (or clear) the footer indicator from the cached status. */
  show(ctx: ExtensionContext): void {
    if (ctx.mode !== "tui") return;
    const status = this.status;
    ctx.ui.setStatus(
      STATUS_KEY,
      status ? this.fragment(ctx.ui.theme, status) : undefined,
    );
  }

  /** Footer fragment: `git:main ●3 ac`. */
  fragment(theme: Theme, status: RepoStatus): string {
    const branch = status.detached ? `@${status.branch}` : status.branch || "?";
    const parts = [
      `${theme.fg("accent", "git")}${theme.fg("dim", ":")}${theme.bold(
        theme.fg("text", branch),
      )}`,
    ];
    if (status.dirty > 0) {
      parts.push(theme.fg("warning", `●${status.dirty}`));
    }
    if (status.ahead > 0 || status.behind > 0) {
      parts.push(theme.fg("muted", `↑${status.ahead}↓${status.behind}`));
    }
    if (this.autoCommit) {
      parts.push(theme.fg("success", "ac"));
    }
    return parts.join(" ");
  }
}
