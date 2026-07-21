---
summary: "How the pieces fit: skills, shared rules, tooling, hooks, and the enforcement chain from editor to CI."
read_when: "You are changing repo structure, the validators, or how skills are discovered by harnesses."
---

# Architecture

## The three layers

1. **Rules** (`AGENTS.md`) — always-on constraints every agent session must obey. Small on purpose: rules compete for the same context budget as the task.
2. **Skills** (`skills/`) — opt-in workflows loaded when their description matches the task. This is where volume lives; a skill costs nothing until routed to.
3. **Tooling** (`scripts/`, `hooks/`, `tests/`, CI) — keeps layers 1 and 2 trustworthy. An unvalidated skill collection rots into misinformation that agents then follow confidently.

## Discovery

Harnesses find skills via `scripts/sync-skills`:

- **Claude Code** scans exactly one level of `~/.claude/skills/`, following per-entry symlinks but not category subfolders → it gets one symlink per skill.
- **Codex** scans nested directories → it gets a single `~/.codex/skills/agents-scripts` link to `skills/`.

A link is *managed* iff its target resolves inside this repo; sync only creates, updates, or prunes managed links and never touches anything else. This makes `sync-skills` safe to run blindly and lets multiple skill repos coexist in the same harness directories.

## Enforcement chain

The same validators (skills, docs, agents, plugin packaging, evals, links) plus the static threat scanner run at three points, strictest-last:

| Point | Trigger | Scope |
|---|---|---|
| `scripts/committer` | you commit through it | validators + link check + exact staging + message format + self-tests on tooling changes |
| `hooks/pre-commit` | any commit, once `core.hooksPath hooks` is set | validators + link check + `bash -n` on staged shell |
| CI (`.github/workflows/ci.yml`) | every push / PR, Ubuntu and macOS | validators + link check + shellcheck + `tests/run-tests.sh` + doctor |

Local checks are conveniences; CI is the guarantee. Both validators accept a repo-root argument, which is what makes the fixture-based tests in `tests/` possible.

## Front matter contract

Skills: `name` (kebab-case, must equal the directory name, unique) and `description` (double-quoted, ≤200 chars), with front-matter keys allow-listed and the body's `# <name>` heading plus `## When to use` / `## Workflow` / `## Pitfalls` sections enforced. Docs: `summary` and `read_when`. Parsing is restricted to simple `key: "value"` lines — this is a *feature*: every harness and a 40-line stdlib parser agree on the semantics, and there are no YAML edge cases to disagree over.

## Extension points

- New skill → `scripts/new-skill` (see `skills/skill-author`).
- New doc → add front matter or CI rejects it.
- New subagent → `agents/<name>.md`; `validate-agents` enforces the format, a real model tier, and an explicit `## Output contract` section.
- Plugin packaging → `.claude-plugin/`; `validate-plugin` checks both manifests and their cross-consistency.
- Skill evals → `evals/<name>/scenarios.json`; `validate-evals` enforces schema and coverage, `eval-skills` runs them on demand (docs/evals.md).
- Security exceptions → explicit `(check, path)` entries in `scripts/scan-security`'s ALLOWLIST, landed as reviewed code changes (policy in SECURITY.md).
- Multi-harness outputs → `scripts/render-rules` derives `.cursor/rules/`, Copilot instructions, `.windsurfrules`, and `GEMINI.md` from skills/ + AGENTS.md; rendered files are committed and `--check` blocks drift in CI.
- Personal/machine-specific rules → untracked `AGENTS.local.md` (gitignored), never the shared files.
- Team-private skills → a sibling overlay repo with the same layout; run its own `sync-skills` alongside this one. Managed-link semantics keep the two from stepping on each other.
