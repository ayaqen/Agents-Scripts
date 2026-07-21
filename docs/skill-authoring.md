---
summary: "The full contract for writing skills: front matter rules, body structure, style, scripts, and review checklist."
read_when: "Writing or reviewing a skill, or changing the validator's rules."
---

# Skill authoring

The short version lives in `skills/skill-author` (agents route there). This doc is the full contract, including the *why*.

## Front matter contract

```yaml
---
name: my-skill
description: "Short generic trigger phrase."
---
```

- `name`: kebab-case, must equal the directory name, unique across the repo. The validator enforces all three.
- `description`: double-quoted, ≤200 chars (aim for ≤120). This is the *only* text the harness sees when deciding whether to load the skill — write it as a trigger, front-loaded with the words a task description would contain.
- Only simple `key: value` lines are allowed. No nesting, lists, multiline strings, or anchors — the restriction is what guarantees every harness parses skills identically.
- Keys are allow-listed: `name`, `description`, `version`, `license`, `allowed-tools`. Anything else is a validation error — extend the list in `scripts/validate-skills` deliberately, not ad hoc.

## Body structure

```markdown
# my-skill
One paragraph: the outcome this skill produces.

## When to use        ← routing confirmation; concrete situations
## Workflow           ← numbered, operational, commands over prose
## Pitfalls           ← earned knowledge; the highest-value section
```

Style rules:

- Terse and operational. A skill is instructions to an agent mid-task, not documentation for a human with coffee.
- Every workflow step should be *checkable* — a command to run or a condition to verify, not a virtue to hold.
- ~80 lines target for the body; the validator hard-fails past 120. The `# <name>` heading and the three `##` sections above are validator-enforced structure, not conventions. Overflow goes to `references/` (loaded only when needed) or `scripts/`.
- Portable: no personal names, machine paths, or private services. Test: does it make sense on a stranger's laptop?

## Helper scripts

- Live in `skills/<name>/scripts/`, bash with `#!/usr/bin/env bash` and `set -euo pipefail` (or `set -uo pipefail` when partial failures are expected and handled).
- Must pass `bash -n` and `shellcheck -S warning` — CI checks every file whose first line mentions bash.
- Must be executable (`chmod +x`) with a shebang first line; the validator checks both, because a non-executable helper fails silently in agent hands.
- Bash 3.2-compatible: no associative arrays, no `readarray`, no `${var,,}`.
- Read-only by default; scripts that mutate state must say so in their header comment and support `--dry-run` where feasible.

## Review checklist for skill PRs

1. `./scripts/validate-skills && ./scripts/validate-links && ./tests/run-tests.sh` pass.
2. Description reads as a trigger, not a summary.
3. No overlap with an existing skill's routing territory — check with `./scripts/explain-routing --overlap` and extend instead of duplicating.
4. Pitfalls section contains real earned knowledge, not padding.
5. Any referenced commands actually exist on a fresh clone.
