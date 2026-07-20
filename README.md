# Agents-Scripts

Portable skills, guardrails, and helper scripts for AI coding agents — Claude Code, Codex, and any harness that understands `SKILL.md` + `AGENTS.md`.

Inspired by [steipete/agent-scripts](https://github.com/steipete/agent-scripts), rebuilt from scratch to be **portable, team-ready, and CI-enforced** instead of bound to one person's machines. See [docs/design-decisions.md](docs/design-decisions.md) for the full review of the original and what changed.

## Why this exists

Agent harnesses are only as good as the instructions and workflows you feed them. This repo is the canonical home for:

- **`AGENTS.md`** — shared hard rules every agent session loads (communication, git safety, verification, secrets).
- **`skills/`** — reusable, harness-agnostic workflow skills. Each is a directory with a `SKILL.md` (validated front matter) and optional helper `scripts/`.
- **`scripts/`** — dependency-free tooling: validate, scaffold, sync, commit, diagnose.
- **`hooks/`** — git hooks so broken skills never land on `main`.

Everything works on a fresh clone, on Linux and macOS, with nothing but `bash`, `git`, and `python3`.

## Quickstart

```bash
git clone https://github.com/ayaqen/Agents-Scripts.git
cd Agents-Scripts

./scripts/doctor              # check your environment
./scripts/validate-skills     # verify every skill parses
./scripts/sync-skills         # link skills into ~/.claude/skills and ~/.codex/skills
git config core.hooksPath hooks   # optional: block commits that break validation
```

Create a new skill:

```bash
./scripts/new-skill my-workflow "Short trigger phrase for routing."
```

Commit with validation and Conventional Commits enforced:

```bash
./scripts/committer -m "feat(skills): add my-workflow" skills/my-workflow/SKILL.md
```

## Repository layout

```
AGENTS.md            Shared hard rules for every agent session
CLAUDE.md            Pointer file for harnesses that only read CLAUDE.md
skills/<name>/       One skill per directory: SKILL.md + optional scripts/
scripts/             validate-skills, validate-docs, new-skill, sync-skills,
                     committer, doctor
templates/skill/     Scaffold used by new-skill
hooks/               pre-commit guardrail
docs/                Architecture, authoring guide, install, design decisions
tests/               Self-tests for the tooling (run in CI)
```

## Skill catalog

| Skill | Use it when |
|---|---|
| [repo-onboarding](skills/repo-onboarding/SKILL.md) | Mapping an unfamiliar codebase before changing it |
| [debug-loop](skills/debug-loop/SKILL.md) | Hypothesis-driven debugging of failing code or tests |
| [regression-fix](skills/regression-fix/SKILL.md) | Fixing a bug with a failing test written first |
| [safe-refactor](skills/safe-refactor/SKILL.md) | Behavior-preserving refactors, verified at each step |
| [self-review](skills/self-review/SKILL.md) | Reviewing your own diff before committing |
| [ci-green](skills/ci-green/SKILL.md) | Driving a failing CI pipeline back to green |
| [release-checklist](skills/release-checklist/SKILL.md) | Cutting and *verifying* a release |
| [dependency-vet](skills/dependency-vet/SKILL.md) | Evaluating a dependency before adding it |
| [session-handoff](skills/session-handoff/SKILL.md) | Writing a handoff so the next session can continue |
| [context-budget](skills/context-budget/SKILL.md) | Working in large codebases without drowning context |
| [prompt-triage](skills/prompt-triage/SKILL.md) | Debugging LLM prompt / agent misbehavior |
| [eval-design](skills/eval-design/SKILL.md) | Designing evals for an LLM-powered feature |
| [skill-author](skills/skill-author/SKILL.md) | Creating or updating skills in this repo |

## Design principles

1. **Portable or it doesn't ship.** No personal paths, no symlinks into sibling repos, no macOS-only assumptions. A fresh clone passes CI anywhere.
2. **One toolchain.** All tooling is bash (3.2-compatible) + python3 stdlib. No Ruby, no bun, no `node_modules` to install before the repo is useful.
3. **Validation is enforced, not suggested.** CI runs the same validators as the pre-commit hook. A skill that doesn't parse cannot merge.
4. **Skills are workflows, not machine inventory.** Personal tool integrations belong in your own overlay repo; this one holds transferable engineering practice.
5. **Front matter is deliberately dumb.** Simple `key: "value"` lines only — parseable by every harness and by a 40-line stdlib parser, with no YAML edge cases.
6. **Local beats global.** Machine-specific rules go in untracked `AGENTS.local.md`, never in shared files.

## CI

Every push and PR runs: `bash -n` + shellcheck on all shell scripts, `validate-skills`, `validate-docs`, and the tooling self-tests in `tests/`. See [.github/workflows/ci.yml](.github/workflows/ci.yml).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) and the [skill authoring guide](docs/skill-authoring.md).

## License

[MIT](LICENSE)
