---
summary: "Deep review of steipete/agent-scripts and the rationale for every structural decision in this repo."
read_when: "You wonder why this repo is shaped the way it is, or want to change one of its conventions."
---

# Design decisions

This repo is a ground-up rebuild informed by a deep review of [steipete/agent-scripts](https://github.com/steipete/agent-scripts). This doc records what that review found, what we kept, and what we deliberately changed.

## What the original gets right (kept)

- **Skills as the routing layer.** `skills/<name>/SKILL.md` with front matter (`name`, quoted `description`) is the correct architecture: descriptions optimized for routing, bodies kept terse and operational, helper scripts co-located under `scripts/`. We kept the structure and the quoting rule.
- **A single shared `AGENTS.md` of hard rules**, with harnesses that only read `CLAUDE.md` pointed at it. Kept, with `CLAUDE.md` as a small real file (portable to Windows and readable on GitHub) rather than a symlink.
- **Validation exists** (`validate-skills`) and can run as a pre-commit hook. Kept and extended.
- **`sync-skills` is idempotent, prints only changes, prunes stale managed links, and never clobbers real files.** Those four properties are exactly right; our version preserves all of them.
- **`committer` stages exactly the listed files and validates first.** Kept, plus Conventional Commit enforcement and a refusal when unrelated files are already staged.
- **Docs carry `summary`/`read_when` front matter** so agents can decide whether to load them. Kept and — unlike the original — enforced in CI.

## What the review found wrong (changed)

1. **Not portable.** The original hardcodes one person's world: `~/Projects`, named Macs, personal GitHub identities, a personal Gmail test account, macOS-only tools. Its `AGENTS.MD` is ~40% personal ops policy. → Here, shared files contain only transferable rules; anything machine- or person-specific goes in untracked `AGENTS.local.md`.
2. **Broken on a fresh clone.** Fourteen skills are symlinks into sibling repos (`../../discrawl/...`); a standalone clone has fourteen dangling links and no validator complaint about them. → No cross-repo symlinks. Skills are real directories; our validator treats a broken symlink under `skills/` as a hard error.
3. **Four toolchains for one repo's tooling.** Ruby (`validate-skills`), TypeScript/bun (`browser-tools`, `docs-list`), Python, and bash — so a contributor needs Ruby *and* bun before the guardrails even run. → One rule: bash (3.2-compatible) + python3 stdlib. Nothing to install.
4. **The validator never runs in CI.** The original's CI builds a browser tool and smoke-tests two helpers, but never calls `validate-skills` or checks docs front matter — the core guarantee is enforced only on machines that opted into the hook. → Our CI runs both validators, shellcheck, and the tooling's own test suite on every push and PR.
5. **No scaffolding.** Skills were created by hand, which is how front matter drift happens. → `new-skill` scaffolds from a template, requires a real description up front, and validates immediately.
6. **Personal integrations instead of transferable practice.** Most original skills wrap one person's tools (Sonos, WhatsApp, personal Macs). Useful to him; dead weight to anyone else. → Our catalog holds engineering workflows (debugging, refactoring, releases, evals, context management) that work in any repo. Tool integrations belong in a private overlay.
7. **Tooling without tests.** Only 2 of the original's helpers had tests. → `tests/run-tests.sh` covers both validators, the scaffolder, and sync idempotency, and runs in CI.
8. **Real YAML in front matter.** The original parses front matter with Ruby's YAML — meaning skills can (and did) drift toward YAML features some harness parsers won't handle. → We restrict front matter to simple `key: "value"` lines and enforce that restriction. Less expressive, universally parseable.

## Decisions that could go either way

- **Symlink-based sync vs copying.** We kept symlinks (edits propagate instantly; single source of truth) despite copy being more robust on Windows. Windows users can use WSL or copy manually; revisit if that population grows.
- **Python for validators, bash for glue.** Pure bash validation was tempting (one language) but front-matter parsing in bash is where correctness goes to die. Python3 stdlib is a fair trade: present everywhere the target harnesses run.
- **13 curated skills, not 67.** Fewer, broader skills route better than many narrow ones — duplicate routing phrases make harness skill-selection unreliable. Growth rule: extend an existing skill before adding a neighbor.
