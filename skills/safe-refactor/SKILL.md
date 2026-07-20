---
name: safe-refactor
description: "Behavior-preserving refactoring in small verified steps, with a rollback path at every point."
---

# safe-refactor

Restructure code without changing behavior, in steps small enough that any breakage is instantly attributable.

## When to use

- Extracting, renaming, moving, or de-duplicating code.
- Preparing ground for a feature ("make the change easy, then make the easy change").
- NOT for behavior changes — if behavior changes, it's a feature or a fix, and it needs its own commit and tests.

## Workflow

1. Establish the safety net: run the tests covering the target code and record the result. Coverage thin? Add characterization tests for current behavior *before* refactoring — they're cheap insurance and a separate commit.
2. Plan the end state in one sentence. If you can't, the refactor is too big — split it.
3. Move in mechanical steps, each independently green: rename, then move, then reshape — never all at once. Use language tooling (IDE rename, codemods) over hand-editing when available.
4. Run the tests after every step. A failure means the *last* step broke it — revert that step, not the whole effort.
5. Commit each coherent step with `refactor(...)`. Small commits are the rollback path.
6. Delete the old path. Leaving both "temporarily" creates a fork that drifts; compatibility shims need a named contract (public API, stored data, config), not vague caution.

## Pitfalls

- The "while I'm here" trap: folding fixes or features into refactor commits destroys reviewability and bisectability.
- Refactoring against a red baseline — you can no longer tell what you broke.
- Trusting type-checks alone as the safety net; they don't catch behavioral drift in dynamic paths.
- Repo-wide mechanical search-and-replace in one commit; reviewers can't verify it, and one edge case poisons the batch.
