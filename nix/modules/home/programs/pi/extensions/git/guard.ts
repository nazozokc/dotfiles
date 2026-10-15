/**
 * git extension — dirty-repo guard.
 *
 * Asks the user before a session is replaced while the work tree has
 * uncommitted changes, so context is not switched with unsaved work. Used for
 * `session_before_switch` and (via index.ts) `session_before_fork`.
 */

import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";

import { readStatus } from "./repo.ts";

/** Result shape shared by the session_before_switch / fork events. */
export interface GuardResult {
  cancel?: boolean;
}

/**
 * Return `{ cancel: true }` when the action should be aborted, otherwise
 * undefined. Headless runs abort by default (there is no one to ask).
 */
export async function checkDirty(
  pi: ExtensionAPI,
  ctx: ExtensionContext,
  action: string,
): Promise<GuardResult | undefined> {
  const status = await readStatus(pi, ctx.cwd);
  if (!status || status.dirty === 0) return;

  if (!ctx.hasUI) return { cancel: true };

  const choice = await ctx.ui.select(
    `You have ${status.dirty} uncommitted change(s). ${action} anyway?`,
    ["Yes, proceed anyway", "No, let me commit first"],
  );
  if (choice === "Yes, proceed anyway") return;

  ctx.ui.notify("Commit your changes first", "warning");
  return { cancel: true };
}
