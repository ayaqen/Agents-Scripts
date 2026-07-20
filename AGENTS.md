# Agent Instructions

Hard rules for AI agent sessions in repos that adopt Agents-Scripts. Skills own tool-specific workflows; this file holds only rules that must always apply.

Machine- or person-specific rules belong in an untracked `AGENTS.local.md` next to this file. If it exists, read it after this file; local rules may tighten these, never loosen them.

## Communication

- Lead with the outcome, then the reasoning. A handoff or final summary must let a teammate who wasn't watching act on it.
- Report reality: failing tests, skipped steps, and partial work are stated plainly, never rounded up to "done".
- Compact updates while working; full sentences and preserved tradeoffs in final summaries.

## Verification

- "It compiles" is not verification. Run the narrowest test or command that proves the actual change works, and show its output.
- After any fix, re-run the command that originally failed.
- Claims about external state (a release published, CI green, a package on a registry) require a fresh read of that state, not memory.

## Git

- Never push, force-push, or change branches without an explicit user request or a workflow that clearly authorizes it.
- Destructive operations (`reset --hard`, `clean`, `restore`, history rewrites) require an explicit ask.
- Commit style: Conventional Commits (`feat|fix|refactor|build|ci|chore|docs|perf|test`). Small, reviewable commits; no repo-wide mechanical rewrites in one commit.
- A dirty working tree you didn't create belongs to someone else. Work around it; on conflict, stop and ask.

## Secrets & disclosure

- Never print secret values — not in logs, commit messages, PR bodies, or debug output. Query exact names; redact values.
- Never send repository content, screenshots, or data to an external service the user hasn't approved for that content.
- When audience or destination is unclear, ask before sending externally.

## Code quality

- Fix the cause, not the symptom. A regression test accompanies any non-trivial bug fix (see `skills/regression-fix`).
- When replacing an old code path, delete it. Compatibility shims need a named contract (public API, config format, stored data) — tests alone don't count.
- Match the surrounding code's style, comment density, and idioms.
- Comments explain constraints the code can't express — never narrate the diff.

## Dependencies

- New dependencies get a health check before adoption (see `skills/dependency-vet`). Use the repo's existing package manager and runtime; swapping either needs approval.

## Docs

- Read a repo's docs before its code.
- User-visible behavior changes update docs and changelog in the same PR.
