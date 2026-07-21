---
summary: "How the semantic eval harness works: scenario schema, running, grading policy, and the no-regression merge rule."
read_when: "Adding or changing a skill (evals are mandatory), running evals, or interpreting results in evals/results/."
---

# Semantic evals

Structural validation proves a skill parses; it says nothing about whether the skill makes an agent *work better*. The eval harness closes that gap: every skill ships graded scenarios, and results are tracked in-repo as the regression baseline. This is the feature the ecosystem evaluation ranked first (see docs/evaluation.md) — quality variance is the space's biggest unsolved problem, and measured beats asserted.

## The two halves

- **`scripts/validate-evals`** — offline, dependency-free, runs in CI. Enforces that every skill has `evals/<name>/scenarios.json`, the schema is correct, and every scenario has a real rubric. Structure is a merge gate.
- **`scripts/eval-skills`** — on-demand, needs an agent CLI and costs tokens, deliberately **not** a CI gate: making it one would break the fork-and-it-works, zero-dependency guarantee and gate merges on a paid API. Semantics are a *policy* gate instead (below).

## Scenario schema

See any `evals/<skill>/scenarios.json` (the exemplar is `evals/debug-loop/scenarios.json`); the schema is documented in `scripts/validate-evals`. The design rules:

- **Criteria are observable behaviors**, not virtues: "re-ran the originally failing command", never "was careful".
- **Every scenario includes at least one negative criterion** — something the skill's Pitfalls section says NOT to do. Skills earn their keep by preventing failure modes, so evals must test for them.
- **Cheapest honest grader first** (per the `eval-design` skill itself): `command` graders for filesystem-checkable facts, `judge` graders only for genuinely semantic judgments.

## Running

```bash
./scripts/eval-skills --list                # what exists (offline)
./scripts/eval-skills --dry-run             # what would run (offline)
./scripts/eval-skills --skill debug-loop    # one skill, for iteration
./scripts/eval-skills                       # full run
```

The agent under test is any CLI that reads a prompt on stdin and prints its transcript (default `claude -p`; override with `EVAL_AGENT_CMD`, judge with `EVAL_JUDGE_CMD`). Judge verdicts must be strict JSON; unparsable judge output counts as **fail**, never as pass — graders get no benefit of the doubt.

## Policy: the no-regression rule

1. A PR that adds or edits a skill must ship matching scenario changes (CI enforces presence and schema).
2. Before merging a skill edit, run `./scripts/eval-skills --skill <name>` and commit the result file. A score drop against the last committed run for that skill needs an explicit justification in the PR, not silence.
3. Results in `evals/results/` are append-only history — never edit or delete old runs; they are the baseline.

## Known limits (v1, honest)

- Fixtures are passed to the agent as *descriptions*, not materialized repos — scenario realism is bounded by that. Materialized fixture workspaces are the planned v2.
- A single judge sample per criterion; stochastic grading variance is real. For load-bearing comparisons, run 3× and compare medians.
- With/without-skill comparison (the "does this skill earn its context cost" number) is designed for but not yet automated — run manually by evaluating with the skill uninstalled.
