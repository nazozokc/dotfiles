/**
 * Codex usage extension
 *
 * Shows the remaining Codex rate-limit usage in the footer while using pi.
 *
 * It spawns a short-lived `codex app-server` (JSON-RPC 2.0 over stdio),
 * performs the `initialize` handshake, calls `account/rateLimits/read`, and
 * renders the result. Codex's own credentials are reused, so no token
 * handling is required here.
 *
 * Commands:
 *   /codex-usage-update   Refresh the footer value immediately
 */

import { spawn } from "node:child_process";
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";

const CODEX_BIN = process.env.CODEX_BIN ?? "codex";
const REFRESH_MS = 5 * 60 * 1000;
const TIMEOUT_MS = 15_000;
const STATUS_KEY = "codex-usage";
const CLIENT_NAME = "pi-codex-usage";
const CLIENT_VERSION = "0.1.0";

type RateLimitWindow = {
  usedPercent?: number;
  windowDurationMins?: number;
  resetsAt?: number;
};

type CreditsSnapshot = {
  hasCredits?: boolean;
  unlimited?: boolean;
  balance?: string | null;
};

type RateLimitSnapshot = {
  limitId?: string;
  limitName?: string | null;
  planType?: string | null;
  primary?: RateLimitWindow | null;
  secondary?: RateLimitWindow | null;
  credits?: CreditsSnapshot | null;
};

type RateLimitsResult = {
  rateLimits?: RateLimitSnapshot | null;
};

function windowLabel(minutes: number | undefined): string | null {
  if (!minutes || minutes <= 0) return null;
  if (minutes % 1440 === 0) return `${minutes / 1440}d`;
  if (minutes % 60 === 0) return `${minutes / 60}h`;
  return `${minutes}m`;
}

function formatWindow(win: RateLimitWindow | null | undefined): string | null {
  if (!win || typeof win.usedPercent !== "number") return null;
  const remaining = Math.max(
    0,
    Math.min(100, Math.round(100 - win.usedPercent)),
  );
  const label = windowLabel(win.windowDurationMins);
  return label ? `${label} ${remaining}%` : `${remaining}%`;
}

function render(snapshot: RateLimitSnapshot | null): string {
  if (!snapshot) return "🤖 codex —";
  const plan = snapshot.planType ? ` (${snapshot.planType})` : "";
  if (snapshot.credits?.unlimited) return `🤖 codex unlimited${plan}`;
  const parts = [
    formatWindow(snapshot.primary),
    formatWindow(snapshot.secondary),
  ].filter((part): part is string => part !== null);
  return `🤖 codex ${parts.length > 0 ? parts.join(" · ") : "—"}${plan}`;
}

/**
 * Spawn a short-lived `codex app-server`, perform the JSON-RPC handshake,
 * read the current rate limits, then terminate the process.
 */
function fetchRateLimits(): Promise<RateLimitSnapshot | null> {
  return new Promise((resolve, reject) => {
    const child = spawn(CODEX_BIN, ["app-server"], {
      stdio: ["pipe", "pipe", "ignore"],
    });

    let settled = false;
    let buffer = "";

    const finish = (fn: () => void) => {
      if (settled) return;
      settled = true;
      clearTimeout(timer);
      try {
        child.kill("SIGTERM");
      } catch {
        // Process may already have exited.
      }
      fn();
    };

    const timer = setTimeout(
      () => finish(() => reject(new Error("codex app-server timed out"))),
      TIMEOUT_MS,
    );

    const send = (message: unknown) => {
      if (!child.stdin) return;
      child.stdin.write(`${JSON.stringify(message)}\n`);
    };

    child.on("error", (error) => finish(() => reject(error)));

    child.stdout?.on("data", (chunk: Buffer) => {
      buffer += chunk.toString();
      let newline = buffer.indexOf("\n");
      while (newline >= 0) {
        const line = buffer.slice(0, newline).trim();
        buffer = buffer.slice(newline + 1);
        newline = buffer.indexOf("\n");
        if (!line) continue;

        let message: { id?: unknown; result?: unknown; error?: unknown };
        try {
          message = JSON.parse(line);
        } catch {
          continue;
        }

        if (message.id === 1) {
          if (message.error) {
            finish(() => reject(new Error("initialize failed")));
            return;
          }
          send({ method: "initialized" });
          send({ id: 2, method: "account/rateLimits/read", params: {} });
        } else if (message.id === 2) {
          if (message.error) {
            finish(() => reject(new Error("account/rateLimits/read failed")));
          } else {
            const result = message.result as RateLimitsResult | undefined;
            finish(() => resolve(result?.rateLimits ?? null));
          }
        }
      }
    });

    send({
      id: 1,
      method: "initialize",
      params: {
        clientInfo: { name: CLIENT_NAME, version: CLIENT_VERSION },
        capabilities: { experimentalApi: true },
      },
    });
  });
}

export default function (pi: ExtensionAPI) {
  let snapshot: RateLimitSnapshot | null = null;
  let timer: ReturnType<typeof setInterval> | null = null;
  let inFlight = false;

  const update = (ctx: ExtensionContext) => {
    ctx.ui.setStatus(STATUS_KEY, render(snapshot));
  };

  const refresh = async (ctx: ExtensionContext) => {
    if (inFlight) return;
    inFlight = true;
    try {
      snapshot = await fetchRateLimits();
    } catch {
      // Keep the last known value; render() shows a placeholder otherwise.
    } finally {
      inFlight = false;
    }
    update(ctx);
  };

  pi.on("session_start", async (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    if (timer) clearInterval(timer);
    update(ctx);
    void refresh(ctx);
    timer = setInterval(() => void refresh(ctx), REFRESH_MS);
  });

  pi.on("session_shutdown", () => {
    if (timer) {
      clearInterval(timer);
      timer = null;
    }
  });

  pi.registerCommand("codex-usage-update", {
    description: "Refresh Codex rate-limit usage shown in the footer",
    handler: async (_args, ctx) => {
      await refresh(ctx);
      ctx.ui.notify(`Codex usage: ${render(snapshot)}`, "info");
    },
  });
}
