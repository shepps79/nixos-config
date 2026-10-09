/**
 * SiriusXM Status Line (ported from ~/.claude-siriusxm/statusline-command.sh)
 *
 * Renders a custom footer that mirrors the Claude Code status line:
 *
 *   | SIRIUSXM |  ~/dir (branch +1) | Model (1M context) | ctx 23% ▓▓░░░░ | 230,079/1,000,000 tok | $14.33 cost | $115.37/$200.00 (resets 2026-07-27)
 *
 * Hardcoded label text: "| SIRIUSXM |", "ctx", "tok", "cost", "(resets ...)".
 * Everything else (dir, git, model, context %, tokens, cost, LiteLLM budget)
 * is dynamic.
 *
 * Colors/icons match the user's Powerlevel10k (classic dark, nerdfont-v3) theme.
 *
 * Enabled automatically on session_start. Use /siriusxm-status to toggle.
 */

import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExecResult, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";

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

interface LitellmState {
	spend: number;
	budget: number | null;
	reset: string | null;
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

export default function (pi: ExtensionAPI) {
	let enabled = false;
	let gitState: GitState | null = null;
	let litellm: LitellmState | null = null;
	let litellmInFlight = false;
	let requestRender: (() => void) | null = null;

	// ---- Background: git status (sync render can't run git, so cache it) ----
	async function refreshGit(cwd: string) {
		const run = async (args: string[]): Promise<ExecResult | null> => {
			try {
				return await pi.exec("git", ["--no-optional-locks", ...args], { cwd, timeout: 3000 });
			} catch {
				return null;
			}
		};

		const inside = await run(["rev-parse", "--is-inside-work-tree"]);
		if (!inside || inside.code !== 0 || inside.stdout.trim() !== "true") {
			if (gitState !== null) {
				gitState = null;
				requestRender?.();
			}
			return;
		}

		let branch = (await run(["symbolic-ref", "--short", "HEAD"]))?.stdout.trim() || "";
		if (!branch) branch = (await run(["describe", "--tags", "--exact-match"]))?.stdout.trim() || "";
		if (!branch) branch = (await run(["rev-parse", "--short", "HEAD"]))?.stdout.trim() || "";
		if (!branch) {
			gitState = null;
			requestRender?.();
			return;
		}

		const porcelain = (await run(["status", "--porcelain"]))?.stdout || "";
		const staged = countLines(porcelain, (l) => /^[MADRC]/.test(l));
		const unstaged = countLines(porcelain, (l) => /^.[MD]/.test(l));
		const untracked = countLines(porcelain, (l) => l.startsWith("??"));
		const conflicted = countLines(porcelain, (l) => /^(UU|AA|DD|AU|UA|UD|DU)/.test(l));

		let ahead = 0;
		let behind = 0;
		const ab = (await run(["rev-list", "--left-right", "--count", "@{upstream}...HEAD"]))?.stdout.trim();
		if (ab) {
			const parts = ab.split(/\s+/);
			behind = parseInt(parts[0] || "0", 10) || 0;
			ahead = parseInt(parts[1] || "0", 10) || 0;
		}

		const stashOut = (await run(["stash", "list"]))?.stdout || "";
		const stashes = stashOut.split("\n").filter((l) => l.length > 0).length;

		gitState = { branch, ahead, behind, stashes, staged, unstaged, untracked, conflicted };
		requestRender?.();
	}

	// ---- Background: LiteLLM real spend/budget (cached 60s) ----
	async function refreshLitellm() {
		const key = process.env.SIRIUSXM_LITELLM_KEY;
		if (!key) return;
		if (litellmInFlight) return; // avoid overlapping requests
		litellmInFlight = true;

		try {
			const controller = new AbortController();
			const timer = setTimeout(() => controller.abort(), 2000);
			const res = await fetch("https://litellm.siriusxm.com/user/info", {
				headers: { Authorization: `Bearer ${key}` },
				signal: controller.signal,
			});
			clearTimeout(timer);
			if (!res.ok) return;
			const data = (await res.json()) as { user_info?: { spend?: number; max_budget?: number | null; budget_reset_at?: string | null } };
			const info = data.user_info ?? {};
			litellm = {
				spend: typeof info.spend === "number" ? info.spend : 0,
				budget: typeof info.max_budget === "number" ? info.max_budget : null,
				reset: info.budget_reset_at ?? null,
			};
			requestRender?.();
		} catch {
			// network/timeout: keep last known value
		} finally {
			litellmInFlight = false;
		}
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
		const effort = ctx.thinkingLevel ?? ctx.getThinkingLevel?.();
		const model = `${ctx.model?.name || "no-model"}${effort ? ` (${effort})` : ""}`;

		// ---- Context usage (percent + bar + tokens) ----
		const usage = ctx.getContextUsage();
		const contextWindow = usage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
		const tokens = usage?.tokens ?? 0;
		let pct = usage?.percent ?? null;
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
		for (const e of ctx.sessionManager.getBranch()) {
			if (e.type === "message" && e.message.role === "assistant") {
				cost += (e.message as AssistantMessage).usage.cost.total;
			}
		}
		const costSegment = `${SEP}${C_COST}$${cost.toFixed(2)} cost${RESET}`;

		// ---- LiteLLM real spend/budget ----
		let litellmSegment = "";
		if (litellm) {
			let s = `${C_COST}$${litellm.spend.toFixed(2)}`;
			if (litellm.budget != null) s += `/$${litellm.budget.toFixed(2)}`;
			if (litellm.reset) s += ` (resets ${litellm.reset.split("T")[0]})`;
			litellmSegment = `${SEP}${s}${RESET}`;
		}

		// ---- Assemble ----
		let line = `${C_LINUX}${ICON_LINUX}${RESET}${SEP}SIRIUSXM${SEP}${C_DIR}${ICON_FOLDER} ${dirDisplay}${RESET}${buildGitSegment()}`;
		line += `${SEP}${C_MODEL}${model}${RESET}`;
		line += `${SEP}ctx ${pctColor}${pctFormatted}%${RESET} ${pctColor}${bar}${RESET}`;
		line += `${SEP}${C_TOKENS}${tokensDisplay}${RESET}`;
		line += `${costSegment}${litellmSegment}`;
		return line;
	}

	function enable(ctx: ExtensionContext) {
		ctx.ui.setFooter((tui, _theme, footerData) => {
			requestRender = () => tui.requestRender();
			const unsub = footerData.onBranchChange(() => {
				void refreshGit(ctx.cwd);
			});
			// initial data
			void refreshGit(ctx.cwd);
			void refreshLitellm();
			return {
				dispose: () => {
					unsub();
					requestRender = null;
				},
				invalidate() {},
				render(width: number): string[] {
					const line = buildLine(ctx);
					return [truncateToWidth(line, width)];
				},
			};
		});
		enabled = true;
	}

	pi.on("session_start", async (_event, ctx) => {
		enable(ctx);
	});

	// Refresh once per prompt, after pi has finished all turns and gone idle
	// (edits/commits have settled, cost/spend is final). Branch-name changes are
	// handled reactively via footerData.onBranchChange in enable().
	pi.on("agent_settled", async (_event, ctx) => {
		if (!enabled) return;
		void refreshGit(ctx.cwd);
		void refreshLitellm();
	});

	pi.registerCommand("siriusxm-status", {
		description: "Toggle the SiriusXM status line (custom footer)",
		handler: async (_args, ctx) => {
			if (enabled) {
				ctx.ui.setFooter(undefined);
				enabled = false;
				ctx.ui.notify("SiriusXM status line disabled", "info");
			} else {
				enable(ctx);
				ctx.ui.notify("SiriusXM status line enabled", "info");
			}
		},
	});
}
