/**
 * Per-mode tool confirmation dialog.
 *
 * Installs a `tool_call` handler that asks the user to approve a call before it
 * runs. Whether the dialog appears is decided by the active agent mode's
 * `confirm` flag (see types.ts), so the same extension gives "ask before every
 * write" in build mode and "just go" in read-only modes.
 *
 * The dialog is skipped when any of these hold:
 *   - the active mode has `confirm: false`,
 *   - the tool is one of the built-in read-only tools or the git tool,
 *   - the tool declares `readOnlyHint: true` (MCP / custom tools),
 *   - no dialog-capable UI is available (headless `pi -p`), where a prompt
 *     would be declined instantly and every call would fail.
 *
 * A declined call is blocked with a reason, which reaches the model as the
 * tool result so it can change approach instead of retrying blindly.
 */
import type {
  ExtensionAPI,
  ToolCallEventResult,
} from "@earendil-works/pi-coding-agent";

/**
 * Tools that agent-modes never confirms: the built-in read-only tools, plus the
 * `git` tool whose writes are gated by the git extension's own dialog. Skipping
 * it here avoids a second prompt for the same call.
 */
const SKIP_CONFIRMATION = new Set(["read", "grep", "find", "ls", "git"]);

/** Longest input preview rendered in the dialog. */
const INPUT_PREVIEW_LIMIT = 200;

/** Shorten a tool call's input to a single preview line. */
function previewInput(input: unknown): string {
  const json = JSON.stringify(input) ?? "{}";
  return json.length > INPUT_PREVIEW_LIMIT
    ? `${json.slice(0, INPUT_PREVIEW_LIMIT)}…`
    : json;
}

/**
 * Install the confirmation handler.
 *
 * @param isConfirmationEnabled decides, at call time, whether the active mode
 *   asks for approval. Read once per tool call so mode switches apply live.
 */
export function installToolConfirmation(
  pi: ExtensionAPI,
  isConfirmationEnabled: () => boolean,
): void {
  pi.on(
    "tool_call",
    async (event, ctx): Promise<ToolCallEventResult | undefined> => {
      if (!isConfirmationEnabled() || !ctx.hasUI) return;
      if (SKIP_CONFIRMATION.has(event.toolName)) return;

      const readOnly = pi
        .getAllTools()
        .find((tool) => tool.name === event.toolName)
        ?.annotations?.readOnlyHint;
      if (readOnly === true) return;

      const approved = await ctx.ui.confirm(
        `Allow ${event.toolName}?`,
        previewInput(event.input),
      );
      if (approved) return;

      return {
        block: true,
        reason: `${event.toolName} was declined by the user`,
      };
    },
  );
}
