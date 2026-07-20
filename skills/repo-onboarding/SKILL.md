---
name: repo-onboarding
description: "Map an unfamiliar codebase before making changes: layout, entry points, conventions, hot spots."
---

# repo-onboarding

Build an accurate mental model of a codebase in minutes, before touching anything. Wrong assumptions made in the first five minutes cost hours later.

## When to use

- First session in a repo you haven't worked in.
- Returning to a repo after significant time or a large refactor landed.
- Before estimating or planning any non-trivial change.

## Workflow

1. Run the mapper for a structural overview:
   ```bash
   ./scripts/repo-map.sh /path/to/repo
   ```
   It prints layout, file census by language, entry points, and the files with the most recent churn (churn ≈ where the action is).
2. Read docs before code, in this order: `README`, `AGENTS.md`/`CLAUDE.md`, `CONTRIBUTING`, then anything in `docs/` whose front matter or title matches your task.
3. Find how the project proves itself: locate the test command (CI workflow files are the ground truth — read `.github/workflows/`) and run it once *before* changing anything, so you know the baseline.
4. Trace one representative path end-to-end (a request, a CLI invocation, a build) and note the layering conventions you see: error handling style, DI patterns, naming.
5. Write down three things: where your change goes, what pattern it should imitate, and which tests must stay green. Only then start editing.

## Pitfalls

- Skipping the baseline test run — you'll later burn time bisecting a failure that was already there.
- Trusting the README's build instructions over CI's. CI is what actually runs; READMEs rot.
- Pattern-matching on the oldest code in the repo. Prefer imitating the most recently *reviewed* code (recent merged PRs) — that reflects current conventions.
