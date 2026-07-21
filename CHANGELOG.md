# Changelog

## Unreleased

- Add model-tiering skill and AGENTS.md delegation rules: frontier-model orchestration with cheaper executor subagents.
- Add pr-review, security-review, and tool-design skills.
- Harden validate-skills: front-matter key allow-list, enforced body structure (`# <name>` heading plus When to use / Workflow / Pitfalls sections), 120-line body cap, 200-char description cap, and executable-bit + shebang checks on skill helper scripts.
- Add validate-links dead-link checker; wired into committer, pre-commit, and CI.
- Harden committer (72-char subject cap, tooling self-tests when tooling files are staged) and new-skill (safe substitution — descriptions with `&`, slashes, or other special characters no longer corrupt output).
- CI: Ubuntu + macOS matrix, read-only permissions, concurrency cancellation, Dependabot for GitHub Actions, PR template, and a security policy.

## 0.1.0 - 2026-07-20

Initial release: a portable rebuild of the agent-scripts concept, informed by a deep review of steipete/agent-scripts (see docs/design-decisions.md).

- 13 harness-agnostic skills covering onboarding, debugging, regression-first fixes, safe refactoring, self-review, CI recovery, releases, dependency vetting, session handoffs, context budgeting, prompt triage, eval design, and skill authoring.
- Shared `AGENTS.md` hard rules with `CLAUDE.md` pointer and untracked `AGENTS.local.md` override convention.
- Zero-dependency tooling (bash 3.2 + python3 stdlib): `validate-skills`, `validate-docs`, `new-skill`, `sync-skills`, `committer`, `doctor`.
- Fixture-based self-tests for all tooling, run in CI alongside shellcheck and both validators.
- Pre-commit guardrail via `core.hooksPath hooks`.
