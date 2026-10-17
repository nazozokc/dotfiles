#!/usr/bin/env -S deno run --allow-read --allow-write --no-lock
const ROOT = Deno.cwd();
const LOCK_PATH = `${ROOT}/nvim/lazy-lock.json`;
const PLUGINS_DIR = `${ROOT}/nvim/lua/plugins`;
const OUTPUT_PATH = `${ROOT}/nix/modules/home/programs/nvim/plugins.nix`;

async function loadLock() {
  const data = await Deno.readTextFile(LOCK_PATH);
  return JSON.parse(data);
}

async function scanPluginSpecs() {
  const mapping: Record<string, string> = {};
  try {
    for await (const e of Deno.readDir(PLUGINS_DIR)) {
      if (!e.isFile || !e.name.endsWith(".lua")) continue;
      const path = `${PLUGINS_DIR}/${e.name}`;
      const content = await Deno.readTextFile(path);
      let m: RegExpExecArray | null;
      const re1 = /"([^"/]+\/[^"/]+\.nvim[^"]*)"/g;
      while ((m = re1.exec(content))) {
        mapping[e.name.replace(/\.lua$/, "")] = m[1];
        mapping[m[1].split("/").pop()!] = m[1];
      }
      const re2 = /"([^"/]+\/[^"/]+)"/g;
      while ((m = re2.exec(content))) {
        const repo = m[1];
        if (repo.endsWith(".nvim")) {
          mapping[e.name.replace(/\.lua$/, "")] = repo;
          mapping[repo.split("/").pop()!] = repo;
        }
      }
    }
  } catch {}
  return mapping;
}

async function main() {
  const lock = await loadLock();
  const specMap = await scanPluginSpecs();
  const entries: Array<[string, string, string]> = [];
  for (const [k, v] of Object.entries(lock)) {
    const name = k;
    const vv = v as any;
    let repo = vv.repo;
    let rev = vv.rev || vv.commit;
    if (!repo && name.includes("/")) repo = name;
    if (!repo) {
      if (specMap[name]) repo = specMap[name];
      else if (specMap[name.replace(/\.nvim$/, "")]) repo = specMap[name.replace(/\.nvim$/, "")];
      else {
        for (const r of Object.values(specMap)) {
          const rn = (r as string).split("/").pop()!;
          if (rn === name) { repo = r as string; break; }
        }
      }
    }
    if (!repo || !rev) continue;
    const parts = repo.split("/");
    const [owner, repoName] = parts.length > 1 ? [parts[0], parts.slice(1).join("/")] : [repo, repo];
    entries.push([owner, repoName, rev]);
  }
  const seen = new Set<string>();
  const uniq: Array<[string, string, string]> = [];
  for (const [o, rn, r] of entries) {
    const key = o + "/" + rn;
    if (seen.has(key)) continue;
    seen.add(key);
    uniq.push([o, rn, r]);
  }
  uniq.sort((a, b) => (a[0].toLowerCase() + a[1].toLowerCase() < b[0].toLowerCase() + b[1].toLowerCase()) ? -1 : 1);
  const lines: string[] = [];
  lines.push("{ pkgs, lib }:");
  lines.push("let");
  lines.push("  buildVimPluginFromLock = { owner, repo, rev, sha256 ? lib.fakeSha256 }:");
  lines.push("    pkgs.vimUtils.buildVimPlugin {");
  lines.push("      pname = repo;");
  lines.push("      version = builtins.substring 0 7 rev;");
  lines.push("      src = pkgs.fetchFromGitHub { inherit owner repo rev sha256; };");
  lines.push("    };");
  lines.push("");
  lines.push("  known = with pkgs.vimPlugins; [");
  lines.push("  ];");
  lines.push("");
  lines.push("  fromLock = map (p: buildVimPluginFromLock {");
  lines.push("    owner = p.owner;");
  lines.push("    repo  = p.repo;");
  lines.push("    rev   = p.rev;");
  lines.push("    sha256 = p.sha256 or lib.fakeSha256;");
  lines.push("  }) [");
  for (const [o, rn, r] of uniq) {
    lines.push(`    { owner = "${o}"; repo = "${rn}"; rev = "${r}"; sha256 = lib.fakeSha256; }`);
  }
  lines.push("  ];");
  lines.push("in");
  lines.push("known ++ fromLock");
  lines.push("");
  await Deno.writeTextFile(OUTPUT_PATH, lines.join("\n"));
  console.log(`[gen-plugins] Wrote ${uniq.length} plugins to ${OUTPUT_PATH}`);
}
main();
