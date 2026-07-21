# Changelog

## Unreleased

- Add semantic eval harness: graded scenarios for every skill in `evals/` (50 scenarios across 17 skills), offline `validate-evals` gate wired into committer, pre-commit, and CI, and on-demand `eval-skills` runner with judge + command graders (policy in docs/evals.md).
- Add scan-security static threat scanner (unicode smuggling, curl-pipe-shell, base64-exec, opaque blobs, agent-steering phrases, credential probes, network-in-helpers) as a dedicated CI job, wired into committer and pre-commit; disclosed scanning policy and manual security-auditor deep-review layer documented in SECURITY.md.

## 0.2.0 - 2026-07-21

- Add model-tiering skill and AGENTS.md delegation rules: frontier-model orchestration with cheaper executor subagents.
- Add pr-review, security-review, and tool-design skills.
- Harden validate-skills: front-matter key allow-list, enforced body structure (`# <name>` heading plus When to use / Workflow / Pitfalls sections), 120-line body cap, 200-char description cap, and executable-bit + shebang checks on skill helper scripts.
- Add validate-links dead-link checker; wired into committer, pre-commit, and CI.
- Harden committer (72-char subject cap, tooling self-tests when tooling files are staged) and new-skill (safe substitution — descriptions with `&`, slashes, or other special characters no longer corrupt output).
- CI: Ubuntu + macOS matrix, read-only permissions, concurrency cancellation, Dependabot for GitHub Actions, PR template, and a security policy.
- Ship Claude Code plugin packaging (`.claude-plugin/plugin.json` + `marketplace.json`): one-line install via `/plugin marketplace add ayaqen/Agents-Scripts`.
- Add five tiered subagents with validator-enforced output contracts: code-reviewer, security-auditor, bug-hunter, test-writer, mechanical-editor.
- Add validate-agents and validate-plugin; ban dynamic shell preprocessing in skill bodies; wire all five validators into committer, pre-commit, and CI.
- Reposition README around the ecosystem evaluation; add docs/evaluation.md with landscape findings, ranked demand signals, feature mapping, and roadmap.

## 0.1.0 - 2026-07-20

Initial release: a portable rebuild of the agent-scripts concept, informed by a deep review of steipete/agent-scripts (see docs/design-decisions.md).

- 13 harness-agnostic skills covering onboarding, debugging, regression-first fixes, safe refactoring, self-review, CI recovery, releases, dependency vetting, session handoffs, context budgeting, prompt triage, eval design, and skill authoring.
- Shared `AGENTS.md` hard rules with `CLAUDE.md` pointer and untracked `AGENTS.local.md` override convention.
- Zero-dependency tooling (bash 3.2 + python3 stdlib): `validate-skills`, `validate-docs`, `new-skill`, `sync-skills`, `committer`, `doctor`.
- Fixture-based self-tests for all tooling, run in CI alongside shellcheck and both validators.
- Pre-commit guardrail via `core.hooksPath hooks`.
