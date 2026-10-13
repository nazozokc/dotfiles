/**
 * Editor extension
 *
 * Edits the prompt input in an external editor.
 *
 * Flow:
 *   1. Write the current input text to a temporary markdown file
 *   2. Launch $VISUAL / $EDITOR (fallback: vi) on the file
 *   3. When the editor exits cleanly, read the file and set it
 *      as the prompt input with `ctx.ui.setEditorText()`
 *   4. Delete the temporary file in all cases
 *
 * Commands:
 *   /editor   Edit the prompt input in the external editor
 */

import { spawn } from "node:child_process";
import { mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/** Resolve the external editor command and its arguments from the environment. */
function resolveEditor(): string[] {
  const envEditor = process.env.VISUAL ?? process.env.EDITOR;
  if (envEditor) return envEditor.split(" ");
  return ["vi"];
}

/**
 * Open a temporary file in the external editor and return its content.
 * Returns null when the editor exits with a non-zero status.
 */
async function editInEditor(content: string): Promise<string | null> {
  const directory = await mkdtemp(join(tmpdir(), "pi-editor-"));
  const filePath = join(directory, "prompt.md");
  try {
    await writeFile(filePath, content, "utf-8");
    const [editor, ...editorArgs] = resolveEditor();
    process.stdout.write(
      `Launching external editor: ${editor}\nPi will resume when the editor exits.\n`,
    );
    // stdio: "inherit" lets the TUI yield the terminal to the editor and
    // regain it on exit, mirroring pi's own editInExternalEditor().
    const exitCode = await new Promise<number | null>((resolve) => {
      const child = spawn(editor, [...editorArgs, filePath], {
        stdio: "inherit",
        shell: process.platform === "win32",
      });
      child.on("error", () => resolve(null));
      child.on("close", (code) => resolve(code));
    });
    if (exitCode !== 0) return null;
    // Drop the BOM and the trailing newline editors add, matching the
    // input normalization pi uses for its built-in external editor.
    return (await readFile(filePath, "utf-8"))
      .replace(/^\uFEFF/, "")
      .replace(/\n$/, "");
  } finally {
    try {
      await rm(directory, { recursive: true, force: true });
    } catch {
      // Cleanup is best effort.
    }
  }
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("editor", {
    description: "Edit the prompt input in the external editor",
    handler: async (_args, ctx) => {
      if (ctx.mode !== "tui") {
        ctx.ui.notify("/editor is only available in the TUI", "warning");
        return;
      }
      const content = await editInEditor(ctx.ui.getEditorText());
      if (content === null) {
        ctx.ui.notify("Editor exited with an error; input unchanged", "warning");
        return;
      }
      ctx.ui.setEditorText(content);
    },
  });
}