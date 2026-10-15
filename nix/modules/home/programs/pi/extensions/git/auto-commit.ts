/**
 * git extension — auto-commit on exit.
 *
 * When enabled with `/git autocommit` (default off), commits any uncommitted
 * changes on session shutdown. The subject is derived from the last assistant
 * message and prefixed with `[pi]`.
 */

import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";

import { git } from "./repo.ts";

/** Longest auto-generated commit subject. */
const SUBJECT_LIMIT = 50;

/** Last assistant message as plain text (empty when none). */
function lastAssistantText(ctx: ExtensionContext): string {
  const entries = ctx.sessionManager.getEntries();
  for (let i = entries.length - 1; i >= 0; i--) {
    const entry = entries[i];
    if (entry.type !== "message" || entry.message.role !== "assistant")
      continue;
    const content = entry.message.content;
    if (typeof content === "string") return content;
    if (Array.isArray(content)) {
      return content
        .filter(
          (part): part is { type: "text"; text: string } =>
            typeof part === "object" &&
            part !== null &&
            "type" in part &&
            part.type === "text" &&
            "text" in part &&
            typeof part.text === "string",
        )
        .map((part) => part.text)
        .join("\n");
    }
  }
  return "";
}

export function installAutoCommit(
  pi: ExtensionAPI,
  isEnabled: () => boolean,
): void {
  pi.on("session_shutdown", async (_event, ctx) => {
    if (!isEnabled()) return;

    const status = await git(pi, ["status", "--porcelain"], ctx.cwd);
    if (status.code !== 0 || status.stdout.trim().length === 0) return;

    const text = lastAssistantText(ctx);
    const subjectLine =
      text.split("\n").find((line) => line.trim().length > 0) ?? "";
    const subject = subjectLine.trim() || "work in progress";
    const message = `[pi] ${
      subject.length > SUBJECT_LIMIT
        ? `${subject.slice(0, SUBJECT_LIMIT)}…`
        : subject
    }`;

    const add = await git(pi, ["add", "-A"], ctx.cwd);
    if (add.code !== 0) return;
    const res = await git(pi, ["commit", "-m", message], ctx.cwd);
    if (res.code === 0 && ctx.hasUI) {
      ctx.ui.notify(`Auto-committed: ${message}`, "info");
    }
  });
}
