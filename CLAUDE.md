Read `AGENTS.md` in this directory before anything else. All shared agent rules live there; this file exists only for harnesses that load `CLAUDE.md` by name.

Repo-specific notes for Claude Code:

- Validate after editing any skill or doc: `./scripts/validate-skills && ./scripts/validate-docs`
- Prefer `./scripts/committer -m "<conventional message>" <files...>` for commits — it validates before committing and stages exactly the listed files.
- Run `./tests/run-tests.sh` after changing anything under `scripts/`.
