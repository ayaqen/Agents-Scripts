---
name: regression-fix
description: "Fix a bug by writing the failing regression test first, then making it pass."
---

# regression-fix

Test-first bug fixing. The failing test is both the proof you understood the bug and the guarantee it stays fixed.

## When to use

- Any confirmed bug in code that has (or should have) a test suite.
- Especially when the bug already escaped once — a regression of a regression means the first fix shipped without a test.

## Workflow

1. Diagnose to root cause first (see `debug-loop`). A regression test written against a symptom pins the wrong behavior.
2. Write a test that fails **for the right reason**: run it, and check the failure message describes the actual bug, not a setup error or typo.
3. Name it so future readers find the story: reference the issue number or describe the scenario (`test_parser_handles_crlf_only_input`, not `test_bug`).
4. Put it where the suite conventions say it belongs — next to existing tests for the same module, matching their style and fixtures.
5. Apply the smallest fix that makes it pass. Resist bundling refactors; those go in a separate commit if genuinely needed.
6. Run the new test, then the surrounding suite. Both green → commit test and fix together (`fix(...): ...`) so the pair can never be separated by a revert.

## Pitfalls

- Writing the test after the fix "to save time" — you never see it fail, so you don't know it tests anything. If you did fix first, `git stash` the fix and watch the test fail.
- Over-broad tests that assert on incidental details; they'll break on unrelated changes and get deleted, taking your protection with them.
- Skipping the test because "it's a one-liner". One-line bugs recur exactly as often as big ones.
