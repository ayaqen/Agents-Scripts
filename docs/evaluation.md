---
summary: "Competitive evaluation of the agent-skills ecosystem, ranked user-demand signals, and how this repo's features map to them."
read_when: "Deciding what to build next, questioning the repo's positioning, or updating the README's ecosystem claims."
---

# Ecosystem evaluation

Research conducted July 2026 via web survey of the major agent-skills repos and user-demand signals (Reddit, Hacker News, GitHub issues, security research). Star counts are directional — cross-checked against multiple snapshots, not a live API read. This doc drives the feature set; update it before repositioning the repo.

## Landscape

| Project | ~Stars | Ships | Install story | Validation story |
|---|---|---|---|---|
| obra/superpowers | ~250k | Enforced methodology + plugin loader (~12 core skills) | One-line plugin install, 10 harnesses | Separate evals repo; content repo archived |
| anthropics/skills | ~160k | 17 official skills (docx/pdf/pptx/xlsx power Claude.ai) | Plugin marketplace + API + UI upload | Real CI: front-matter spec + script tests |
| hesreallyhim/awesome-claude-code | ~50k | Curated link list (no content) | None (linkboard) | Schema-validated README generation |
| PatrickJS/awesome-cursorrules | ~40k | 170+ Cursor rule files | Manual copy | None |
| wshobson/agents | ~37k | 94 plugins / 203 agents / 175 skills / 109 commands | Marketplace + npx, 6 harnesses | Static + LLM-judge + statistical eval harness |
| vercel-labs/skills (skills.sh) | ~27k | CLI + registry (~670k listed skills) | `npx skills add owner/repo` | Explicitly none (zero curation) |
| VoltAgent/awesome-claude-code-subagents | ~21k | 154+ subagents, 10 categories | Marketplace + installers | CI present, scope unclear |
| steipete/agent-scripts | ~6k | Personal skills + local tooling | Clone + sync script | Local validator, not in CI |

**Reading:** the top of the table is dominated by projects with a **one-command install**; content volume alone (170+ rules, 154+ agents) lands mid-table. Validation is rare — only anthropics/skills gates PRs on spec compliance in CI, and only cursor.directory (site, not repo) security-scans submissions. Nobody does both.

## Ranked demand signals

1. **Trust/security of third-party skills** — documented prompt-injection attacks through skills, hooks, and the plugin channel; ~50 published permission-bypass techniques; official marketplaces with no automated vetting.
2. **Quality variance** — a community audit scored ~73% of 214 sampled community skills below 60/100, most failing silently.
3. **Token/context bloat** — every installed skill's metadata loads every turn; users measure tens of thousands of wasted tokens per call from oversized catalogs.
4. **Install/discovery friction** — manual copy flows lose to `/plugin install` and `npx skills add`.
5. **Cross-tool portability** — CLAUDE.md vs AGENTS.md vs `.cursor/rules` duplication; AGENTS.md is the emerging convention.
6. **Heavyweight-framework backlash** — praise for enforced discipline, pushback on token cost for simple tasks ("burned through my plan").
7. **Marketplace vetting absent** — users advised to prefer repos with disclosed validation policies.
8. **Trigger opacity** — users can't tell which skill fired or why one didn't.

## Feature mapping (signal → what this repo ships)

| Signal | Response |
|---|---|
| 1, 7 Trust | Static security properties enforced by validator: `` !` `` dynamic-shell preprocessing banned in skill bodies; front-matter keys allow-listed (no smuggled `hooks`/`shell`/`context` config); zero dependencies; helpers make no network calls; SECURITY.md threat model |
| 2 Quality | Every file CI-gated: structure, links, shellcheck, executable bits, output contracts on agents; 60+ fixture self-tests, two OSes |
| 3 Bloat | 200-char description cap and 120-line body cap are validator rules, not style advice; deliberately small catalog (17 skills + 5 agents) |
| 4 Install | `.claude-plugin/` marketplace + plugin manifests (checked by `validate-plugin`); skills-CLI-compatible layout; `sync-skills` for manual/Codex |
| 5 Portability | AGENTS.md + SKILL.md open formats; CLAUDE.md pointer pattern; bash 3.2 + python3 stdlib |
| 6 Backlash | Skills are opt-in workflows, not an enforced pipeline — no mandatory wrapper around simple tasks |
| 8 Triggering | `scripts/explain-routing` ranks which skill a task phrase routes to with matched-term evidence and flags competing territories (`--overlap`); descriptions written as routing triggers; every skill invocable explicitly as `/skill-name` |

## Roadmap (evidence-backed, in priority order)

1. **Semantic eval harness** — SHIPPED: graded scenarios for every skill in `evals/`, structural coverage gate in CI, on-demand LLM-judge runner (`scripts/eval-skills`), results tracked in-repo (docs/evals.md). Next iterations: materialized fixture workspaces and automated with/without-skill comparison.
2. **Contribution security scan** — SHIPPED (static layer): deterministic threat scanner (`scripts/scan-security`) runs on every PR with a disclosed policy in SECURITY.md, plus maintainer deep-review of contribution diffs using the in-repo security-auditor agent. The repo now combines spec CI + security scanning — the pairing the landscape survey found nowhere else. Next iteration: LLM-graded diff review as an optional CI job.
3. **Multi-harness rendering** — SHIPPED: `scripts/render-rules` generates committed Cursor rules, Copilot instructions, Windsurf rules, and GEMINI.md from skills/ + AGENTS.md, with drift blocked in CI via `--check` — the anti-rot mechanism that makes committed generated output safe. Catalog-style targets (Copilot/Windsurf/Gemini) index skills rather than inlining bodies, preserving token discipline.
4. **Trigger observability** — SHIPPED: `scripts/explain-routing "<task phrase>"` ranks skills by lexical routing signal with matched-term evidence and an ambiguity warning; `--overlap` audits the catalog for competing routing territories. Deliberately deterministic and offline — it approximates and explains LLM routing rather than replicating it (caveat documented in the tool). Its first run against the live catalog found and fixed a real routing gap in debug-loop's description.
