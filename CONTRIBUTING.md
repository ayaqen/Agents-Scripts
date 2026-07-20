# Contributing

## Ground rules

- Everything must work on a fresh clone with only `git`, `bash` 3.2+, and `python3`. No new toolchains without a design discussion first (see [docs/design-decisions.md](docs/design-decisions.md)).
- Shared files stay portable: no personal paths, identities, or machine-specific assumptions. That content goes in your untracked `AGENTS.local.md` or a private overlay repo.
- Conventional Commits (`feat|fix|refactor|build|ci|chore|docs|perf|test`).

## Workflow

```bash
git config core.hooksPath hooks        # once
./scripts/new-skill <name> "<desc>"    # for new skills — don't hand-create
./scripts/validate-skills && ./scripts/validate-docs
./tests/run-tests.sh                   # required after touching scripts/
./scripts/committer -m "feat(skills): ..." <files...>
```

## What gets accepted

- **Skills:** transferable engineering workflows. See the review checklist in [docs/skill-authoring.md](docs/skill-authoring.md). Personal tool wrappers won't be merged — broad skills route better than many narrow ones, so prefer extending an existing skill.
- **Tooling:** must come with tests in `tests/run-tests.sh` and pass shellcheck.
- **Docs:** must carry `summary`/`read_when` front matter (CI enforces it).
