---
name: self-review
description: "Review your own diff like a hostile reviewer before committing or opening a PR."
---

# self-review

A structured pass over your own changes before anyone (human or CI) sees them. Cheapest possible review round: the one that never happens because you caught it first.

## When to use

- Before every commit of non-trivial work.
- Before marking a PR ready for review.
- After an agent session produced a large diff quickly — speed of generation is not evidence of correctness.

## Workflow

1. Read the full diff cold: `git diff` (or `git diff --cached`), top to bottom, as if someone else wrote it.
2. For each hunk ask, in order:
   - **Correctness:** what input or state makes this line wrong? Check boundaries, empty cases, error paths, concurrency.
   - **Scope:** does this hunk serve the stated task? Unrelated drive-by edits get split out or reverted.
   - **Leftovers:** debug prints, commented-out code, TODOs without owners, stray files (`git status` for untracked strays).
   - **Consistency:** naming and patterns match the surrounding file, not your habits.
3. Check the negative space — what the diff *doesn't* touch: callers of changed signatures, docs and changelog for user-visible behavior, tests for new branches, config for new options.
4. Re-run the narrowest proving command and read its output; don't rely on an earlier run from before your last edit.
5. Only findings fixed or consciously accepted? Commit with a message that says *why*, not just what.

## Pitfalls

- Reviewing from memory of what you intended instead of what the diff says. Read the actual bytes.
- Rubber-stamping your own large diff because you're tired — that's exactly when step 2 matters. Take the hunks in reverse order to break the skim.
- Fixing review findings and then not re-running the tests (step 4 applies again after every fix).
