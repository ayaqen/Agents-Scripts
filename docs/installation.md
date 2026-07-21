---
summary: "Cloning, syncing skills into Claude Code / Codex, enabling the pre-commit hook, and uninstalling."
read_when: "Setting up Agents-Scripts on a new machine or removing it."
---

# Installation

## Requirements

`git`, `bash` (3.2+, so stock macOS works), and `python3`. Nothing else — no package installs.

## One-line install (Claude Code plugin)

```text
/plugin marketplace add ayaqen/Agents-Scripts
/plugin install agents-scripts@agents-scripts
```

Installs the skills and subagents natively; every skill also becomes a `/skill-name` slash command. The repo layout is also compatible with `npx skills add ayaqen/Agents-Scripts` (skills-CLI ecosystem, 70+ agent runtimes). The manual path below remains for Codex and for working on the repo itself.

## Manual install

```bash
git clone https://github.com/ayaqen/Agents-Scripts.git
cd Agents-Scripts
./scripts/doctor          # verify environment
./scripts/sync-skills     # link skills into harness directories
```

`sync-skills` targets `~/.claude/skills` (per-skill links) and `~/.codex/skills` (one root link). Override with `CLAUDE_SKILLS_DIR` / `CODEX_SKILLS_DIR`; preview with `--dry-run`. It is idempotent and prints only changes — run it after every pull or new skill.

## Shared agent rules

Point your global harness config at this repo's `AGENTS.md`:

```bash
ln -s "$(pwd)/AGENTS.md" ~/.codex/AGENTS.md
ln -s "$(pwd)/AGENTS.md" ~/.claude/CLAUDE.md    # Claude Code reads CLAUDE.md only
```

This is deliberately manual, not part of `sync-skills`: overwriting a user's global instruction file is not something a script should decide. If you already have a global file, add one pointer line to it instead:

```text
READ <path-to>/Agents-Scripts/AGENTS.md BEFORE ANYTHING (skip if missing).
```

Downstream repos use the same pointer pattern, with repo-specific rules below the pointer — never copies of the shared blocks (copies drift).

## Per-machine overrides

Put machine- or person-specific rules in `AGENTS.local.md` next to `AGENTS.md`. It's gitignored; shared files stay portable.

## Enable the commit guardrail (recommended)

```bash
git config core.hooksPath hooks
```

## Uninstall

```bash
rm -rf <clone>            # then:
./scripts/sync-skills     # if run from a surviving clone, prunes dead links; otherwise
                          # delete dangling links in ~/.claude/skills and ~/.codex/skills
```
