/**
 * pi extension load check.
 *
 * Uses pi's own loader so drift in the runtime (new required registration
 * field, broken import, duplicate command name) fails here instead of at
 * startup. Expected registrations are pinned below.
 */
import assert from "node:assert/strict";
import { discoverAndLoadExtensions } from "./node_modules/@earendil-works/pi-coding-agent/dist/core/extensions/loader.js";

const paths = [
  "./extensions/codex-usage.ts",
  "./extensions/editor.ts",
  "./extensions/nazozokc-pi",
  "./extensions/agent-modes",
  "./extensions/parallel-agents",
  "./extensions/git",
];

const result = await discoverAndLoadExtensions(paths, process.cwd());
assert.equal(
  result.errors.length,
  0,
  `load errors: ${JSON.stringify(result.errors)}`,
);
assert.equal(result.extensions.length, paths.length);

const byName = new Map<string, (typeof result.extensions)[number]>();
for (const extension of result.extensions) {
  const name = extension.path
    .split("/extensions/")[1]
    .replace(/(?:^|\/)index\.ts$/, "")
    .replace(/\.ts$/, "");
  assert.ok(name, `cannot derive name from ${extension.path}`);
  assert.ok(!byName.has(name), `duplicate extension: ${name}`);
  byName.set(name, extension);
}

const expected = {
  "codex-usage": {
    commands: ["codex-usage-update"],
    tools: [],
    shortcuts: [],
  },
  editor: { commands: ["editor"], tools: [], shortcuts: [] },
  "nazozokc-pi": {
    commands: ["nazozokc-pi"],
    tools: [],
    shortcuts: ["alt+h", "alt+i", "alt+s"],
  },
  "agent-modes": {
    commands: [
      "agent-modes",
      "build",
      "dangerously-skip-permission",
      "explore",
      "plan",
      "scout",
      "summary",
      "title",
    ],
    tools: [],
    shortcuts: ["tab"],
  },
  "parallel-agents": { commands: [], tools: ["parallel"], shortcuts: [] },
  git: { commands: ["git"], tools: ["git"], shortcuts: [] },
} as const;

assert.deepEqual([...byName.keys()].sort(), Object.keys(expected).sort());

for (const [name, want] of Object.entries(expected)) {
  const extension = byName.get(name);
  assert.ok(extension, `missing extension: ${name}`);
  assert.deepEqual(
    [...extension.commands.keys()].sort(),
    [...want.commands].sort(),
    `${name} commands`,
  );
  assert.deepEqual(
    [...extension.tools.keys()].sort(),
    [...want.tools].sort(),
    `${name} tools`,
  );
  assert.deepEqual(
    [...extension.shortcuts.keys()].sort(),
    [...want.shortcuts].sort(),
    `${name} shortcuts`,
  );
}

console.log(
  `pi-check: loaded ${result.extensions.length} extensions, registrations match`,
);
