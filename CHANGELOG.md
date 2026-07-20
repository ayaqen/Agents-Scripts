# Changelog

## Unreleased

## 0.1.0 - 2026-07-20

Initial release: a portable rebuild of the agent-scripts concept, informed by a deep review of steipete/agent-scripts (see docs/design-decisions.md).

- 13 harness-agnostic skills covering onboarding, debugging, regression-first fixes, safe refactoring, self-review, CI recovery, releases, dependency vetting, session handoffs, context budgeting, prompt triage, eval design, and skill authoring.
- Shared `AGENTS.md` hard rules with `CLAUDE.md` pointer and untracked `AGENTS.local.md` override convention.
- Zero-dependency tooling (bash 3.2 + python3 stdlib): `validate-skills`, `validate-docs`, `new-skill`, `sync-skills`, `committer`, `doctor`.
- Fixture-based self-tests for all tooling, run in CI alongside shellcheck and both validators.
- Pre-commit guardrail via `core.hooksPath hooks`.
