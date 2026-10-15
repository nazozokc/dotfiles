/**
 * git extension — composition root.
 *
 * Wires four capabilities onto one shared GitState:
 *   A. session protection — dirty-repo guard + opt-in auto-commit on exit,
 *   B. turn checkpoints   — stash per turn, offered on fork,
 *   C. commands           — `/git status|log|diff|commit|switch|push|pull|stash|autocommit`,
 *   D. the `git` tool      — classified read/write operations with write approval.
 *
 * All registration lives here; behavior lives in the sibling modules.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

import { installAutoCommit } from "./auto-commit.ts";
import { installCheckpoint, restoreCheckpoint } from "./checkpoint.ts";
import { registerGitCommands } from "./commands.ts";
import { checkDirty } from "./guard.ts";
import { GitState } from "./state.ts";
import { registerGitTool } from "./tool.ts";

export default function gitExtension(pi: ExtensionAPI): void {
  const state = new GitState(pi);

  // D: the model-callable tool + its own write-approval dialog.
  registerGitTool(pi);

  // C: the /git command.
  registerGitCommands(pi, state);

  // B: per-turn checkpoints.
  const checkpoints = installCheckpoint(pi);

  // A: opt-in auto-commit on shutdown.
  installAutoCommit(pi, () => state.autoCommit);

  // A: guard session replacement when the work tree is dirty.
  pi.on("session_before_switch", async (event, ctx) => {
    const action =
      event.reason === "new" ? "Start a new session" : "Switch session";
    return checkDirty(pi, ctx, action);
  });

  // A + B: on fork, first offer the matching checkpoint, then fall back to the
  // dirty guard (so a fork never pops two dialogs).
  pi.on("session_before_fork", async (event, ctx) => {
    const ref = checkpoints.get(event.entryId);
    if (ref && ctx.hasUI) {
      const choice = await ctx.ui.select("Restore code state?", [
        "Restore code to that point",
        "No, keep current code",
        "Cancel",
      ]);
      if (choice === "Restore code to that point") {
        await restoreCheckpoint(pi, ctx, ref);
        return;
      }
      if (choice === "Cancel") return { cancel: true };
    }
    return checkDirty(pi, ctx, "Fork the session");
  });

  // Footer indicator: resetExtensionUI clears it on session switch/fork/new and
  // /reload, so repaint on session start and refresh after each turn.
  pi.on("session_start", async (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    await state.refreshAndShow(ctx);
  });
  pi.on("turn_end", async (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    await state.refreshAndShow(ctx);
  });
}
