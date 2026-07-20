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

The same two validators run at three points, strictest-last:

| Point | Trigger | Scope |
|---|---|---|
| `scripts/committer` | you commit through it | validators + exact staging + message format |
| `hooks/pre-commit` | any commit, once `core.hooksPath hooks` is set | validators + `bash -n` on staged shell |
| CI (`.github/workflows/ci.yml`) | every push / PR | validators + shellcheck + `tests/run-tests.sh` + doctor |

Local checks are conveniences; CI is the guarantee. Both validators accept a repo-root argument, which is what makes the fixture-based tests in `tests/` possible.

## Front matter contract

Skills: `name` (kebab-case, must equal the directory name, unique) and `description` (double-quoted). Docs: `summary` and `read_when`. Parsing is restricted to simple `key: "value"` lines — this is a *feature*: every harness and a 40-line stdlib parser agree on the semantics, and there are no YAML edge cases to disagree over.

## Extension points

- New skill → `scripts/new-skill` (see `skills/skill-author`).
- New doc → add front matter or CI rejects it.
- Personal/machine-specific rules → untracked `AGENTS.local.md` (gitignored), never the shared files.
- Team-private skills → a sibling overlay repo with the same layout; run its own `sync-skills` alongside this one. Managed-link semantics keep the two from stepping on each other.
