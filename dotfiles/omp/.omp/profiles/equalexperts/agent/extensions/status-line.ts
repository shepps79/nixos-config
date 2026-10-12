/**
 * Equal Experts Status Line — omp port of dotfiles/pi/.pi/agent/extensions/status-line.ts
 *
 * Renders the same line as the pi extension:
 *
 *   | EE |  ~/dir (branch +1) | Model | ctx 23% ▓▓░░░░ | 230,079/1,000,000 tok | $14.33 cost
 *
 * Hardcoded label text: "| EE |", "ctx", "tok", "cost".
 * Everything else (dir, git, model, context %, tokens, cost) is dynamic.
 *
 * Colors/icons match the user's Powerlevel10k (classic dark, nerdfont-v3) theme.
 *
 * omp differences from pi:
 *  - `ctx.ui.setFooter` is a no-op stub in omp (StatusLineComponent owns the footer),
 *    so the line is a `belowEditor` widget instead. Widget rows keep raw ANSI, so the
 *    p10k colors survive; `setStatus` would have stripped them.
 *  - No `agent_settled` event: `turn_end` is the settled-turn boundary, and a managed
 *    interval replaces `footerData.onBranchChange` for branch switches.
 *  - Background work uses `ctx.setInterval`, not raw timers: an unhandled throw in a
 *    raw timer callback is a process-level uncaughtException that kills the session.
 *
 * Enabled automatically on session_start. Use /ee-status to toggle.
 */

import type { ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";
import { truncateToWidth } from "@oh-my-pi/pi-tui";

// ---- Colors (256-color ANSI, mirrored from ~/.p10k.zsh) ----
const C_LINUX = "\x1b[38;5;255m"; // penguin icon
const C_DIR = "\x1b[38;5;31m"; // POWERLEVEL9K_DIR_FOREGROUND
const C_GIT_CLEAN = "\x1b[38;5;76m"; // clean/branch/ahead/behind/stash
const C_GIT_MODIFIED = "\x1b[38;5;178m"; // staged/unstaged
const C_GIT_UNTRACKED = "\x1b[38;5;39m"; // untracked
const C_GIT_CONFLICT = "\x1b[38;5;196m"; // conflicted
const C_MODEL = "\x1b[38;5;37m"; // tool/version style segments
const C_META = "\x1b[38;5;246m"; // separators
const C_TOKENS = "\x1b[38;5;244m"; // meta grey
const C_COST = "\x1b[38;5;244m"; // meta grey
const C_PCT_LOW = "\x1b[38;5;76m";
const C_PCT_MED = "\x1b[38;5;178m";
const C_PCT_HIGH = "\x1b[38;5;196m";
const RESET = "\x1b[0m";

// ---- Nerd Font icons ----
const ICON_LINUX = "\uf17c"; // nf-fa-linux (penguin)
const ICON_FOLDER = "\uf115"; // nf-fa-folder
const ICON_GIT = "\ue0a0"; // nf-pl-branch

const SEP = `${C_META} |${RESET} `;

const BAR_SIZE = 6;
const WIDGET_KEY = "ee-status-line";
const REFRESH_MS = 10_000;

interface GitState {
	branch: string;
	ahead: number;
	behind: number;
	stashes: number;
	staged: number;
	unstaged: number;
	untracked: number;
	conflicted: number;
}

interface WidgetUI {
	setWidget?(key: string, content: string[] | undefined, placement?: "aboveEditor" | "belowEditor"): void;
	notify?(message: string, level: "info" | "warn" | "error"): void;
}

// ---- Helpers ----
function addCommas(n: number): string {
	return Math.round(n).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function homeDisplay(cwd: string): string {
	const home = process.env.HOME;
	if (home && (cwd === home || cwd.startsWith(`${home}/`))) {
		return `~${cwd.slice(home.length)}`;
	}
	return cwd;
}

function countLines(text: string, test: (line: string) => boolean): number {
	let count = 0;
	for (const line of text.split("\n")) {
		if (line.length > 0 && test(line)) count++;
	}
	return count;
}

function readAssistantCost(message: object): number {
	if (!("usage" in message)) return 0;
	const usage: unknown = Reflect.get(message, "usage");
	if (!usage || typeof usage !== "object" || !("cost" in usage)) return 0;
	const cost: unknown = Reflect.get(usage, "cost");
	if (!cost || typeof cost !== "object" || !("total" in cost)) return 0;
	const total: unknown = Reflect.get(cost, "total");
	return typeof total === "number" ? total : 0;
}

export default function (pi: ExtensionAPI) {
	pi.setLabel("Equal Experts Status Line");

	let enabled = false;
	let gitState: GitState | null = null;
	let refreshTimer: unknown = null;

	// ---- Background: git status (render is sync, so cache it) ----
	async function refreshGit(cwd: string): Promise<void> {
		const run = async (args: string[]): Promise<string | null> => {
			try {
				const result = await pi.exec("git", ["--no-optional-locks", ...args], { cwd, timeout: 3000 });
				return result.code === 0 ? result.stdout : null;
			} catch {
				return null;
			}
		};

		const inside = await run(["rev-parse", "--is-inside-work-tree"]);
		if (inside?.trim() !== "true") {
			gitState = null;
			return;
		}

		let branch = (await run(["symbolic-ref", "--short", "HEAD"]))?.trim() || "";
		if (!branch) branch = (await run(["describe", "--tags", "--exact-match"]))?.trim() || "";
		if (!branch) branch = (await run(["rev-parse", "--short", "HEAD"]))?.trim() || "";
		if (!branch) {
			gitState = null;
			return;
		}

		const porcelain = (await run(["status", "--porcelain"])) || "";
		const staged = countLines(porcelain, (l) => /^[MADRC]/.test(l));
		const unstaged = countLines(porcelain, (l) => /^.[MD]/.test(l));
		const untracked = countLines(porcelain, (l) => l.startsWith("??"));
		const conflicted = countLines(porcelain, (l) => /^(UU|AA|DD|AU|UA|UD|DU)/.test(l));

		let ahead = 0;
		let behind = 0;
		const ab = (await run(["rev-list", "--left-right", "--count", "@{upstream}...HEAD"]))?.trim();
		if (ab) {
			const parts = ab.split(/\s+/);
			behind = Number.parseInt(parts[0] || "0", 10) || 0;
			ahead = Number.parseInt(parts[1] || "0", 10) || 0;
		}

		const stashOut = (await run(["stash", "list"])) || "";
		const stashes = stashOut.split("\n").filter((l) => l.length > 0).length;

		gitState = { branch, ahead, behind, stashes, staged, unstaged, untracked, conflicted };
	}

	function buildGitSegment(): string {
		if (!gitState) return "";
		const g = gitState;
		let body = `${C_GIT_CLEAN}${ICON_GIT} ${g.branch}`;
		if (g.behind > 0) body += ` ${C_GIT_CLEAN}⇣${g.behind}`;
		if (g.ahead > 0) body += ` ${C_GIT_CLEAN}⇡${g.ahead}`;
		if (g.stashes > 0) body += ` ${C_GIT_CLEAN}*${g.stashes}`;
		if (g.conflicted > 0) body += ` ${C_GIT_CONFLICT}~${g.conflicted}`;
		if (g.staged > 0) body += ` ${C_GIT_MODIFIED}+${g.staged}`;
		if (g.unstaged > 0) body += ` ${C_GIT_MODIFIED}!${g.unstaged}`;
		if (g.untracked > 0) body += ` ${C_GIT_UNTRACKED}?${g.untracked}`;
		return `${SEP}${body}${RESET}`;
	}

	function buildLine(ctx: ExtensionContext): string {
		// ---- Directory ----
		const dirDisplay = homeDisplay(ctx.cwd);

		// ---- Model ----
		const effort = pi.getThinkingLevel();
		const model = `${ctx.model?.name || "no-model"}${effort && effort !== "off" ? ` (${effort})` : ""}`;

		// ---- Context usage (percent + bar + tokens) ----
		const usage = ctx.getContextUsage();
		const contextWindow = usage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
		const tokens = usage?.tokens ?? 0;
		let pct = usage?.percentage ?? null;
		if (pct == null) pct = contextWindow > 0 ? (tokens / contextWindow) * 100 : 0;

		const pctInt = Math.floor(pct);
		const pctColor = pctInt < 50 ? C_PCT_LOW : pctInt < 80 ? C_PCT_MED : C_PCT_HIGH;
		const pctFormatted = `${Math.round(pct)}`;

		let filled = Math.ceil((pct / 100) * BAR_SIZE);
		if (filled < 0) filled = 0;
		if (filled > BAR_SIZE) filled = BAR_SIZE;
		const bar = "▓".repeat(filled) + "░".repeat(BAR_SIZE - filled);

		const usedTokensFmt = addCommas(tokens);
		const tokensDisplay =
			contextWindow > 0 ? `${usedTokensFmt}/${addCommas(contextWindow)} tok` : `${usedTokensFmt} tok`;

		// ---- Session cost (aggregated from branch usage) ----
		let cost = 0;
		for (const entry of ctx.sessionManager.getBranch()) {
			if (entry.type === "message" && entry.message.role === "assistant") {
				cost += readAssistantCost(entry.message);
			}
		}
		const costSegment = `${SEP}${C_COST}$${cost.toFixed(2)} cost${RESET}`;

		// ---- Assemble ----
		let line = `${C_LINUX}${ICON_LINUX}${RESET}${SEP}EE${SEP}${C_DIR}${ICON_FOLDER} ${dirDisplay}${RESET}${buildGitSegment()}`;
		line += `${SEP}${C_MODEL}${model}${RESET}`;
		line += `${SEP}ctx ${pctColor}${pctFormatted}%${RESET} ${pctColor}${bar}${RESET}`;
		line += `${SEP}${C_TOKENS}${tokensDisplay}${RESET}`;
		line += `${costSegment}`;
		return line;
	}

	function render(ctx: ExtensionContext): void {
		if (!enabled) return;
		const ui = ctx.ui as unknown as WidgetUI;
		// A PTY without a window size reports 0, not undefined: `??` would keep it
		// and truncate the whole row away.
		const width = process.stdout.columns || 120;
		ui.setWidget?.(WIDGET_KEY, [truncateToWidth(buildLine(ctx), width)], "belowEditor");
	}

	async function refresh(ctx: ExtensionContext): Promise<void> {
		if (!enabled) return;
		await refreshGit(ctx.cwd);
		render(ctx);
	}

	function enable(ctx: ExtensionContext): void {
		enabled = true;
		render(ctx);
		void refresh(ctx);
		refreshTimer = ctx.setInterval(() => void refresh(ctx), REFRESH_MS);
	}

	function disable(ctx: ExtensionContext): void {
		enabled = false;
		if (refreshTimer) {
			ctx.clearTimer(refreshTimer);
			refreshTimer = null;
		}
		const ui = ctx.ui as unknown as WidgetUI;
		ui.setWidget?.(WIDGET_KEY, undefined, "belowEditor");
	}

	pi.on("session_start", async (_event, ctx) => {
		if (!ctx.hasUI) return;
		enable(ctx);
	});

	// Refresh once per turn, after edits/commits have settled and cost is final.
	// Branch-name changes are picked up by the interval in enable().
	pi.on("turn_end", async (_event, ctx) => {
		await refresh(ctx);
	});

	pi.on("session_shutdown", async (_event, ctx) => {
		disable(ctx);
	});

	pi.registerCommand("ee-status", {
		description: "Toggle the Equal Experts status line (custom widget)",
		handler: async (_args, ctx) => {
			const ui = ctx.ui as unknown as WidgetUI;
			if (enabled) {
				disable(ctx);
				ui.notify?.("Equal Experts status line disabled", "info");
			} else {
				enable(ctx);
				ui.notify?.("Equal Experts status line enabled", "info");
			}
		},
	});
}
