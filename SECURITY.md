# Security Policy

This repo ships agent instructions and dependency-free shell/python tooling — no runtime services, no third-party packages. The surfaces that matter:

- **Scripts run on contributor machines.** Report anything that could make `sync-skills`, `committer`, or the validators destructive or injectable (e.g. crafted file names, descriptions, or front matter reaching a shell).
- **Skills are followed by AI agents.** Report skill content that could steer an agent into unsafe behavior: secret exfiltration, destructive git operations, or prompt-injection vectors.
- **CI workflow changes.** The workflow runs with read-only permissions; report anything that would escalate them.

Report privately via GitHub Security Advisories ("Report a vulnerability" on this repository) and include a reproduction. Please do not open public issues for suspected vulnerabilities.

## Automated scanning of contributions

Every PR and push runs `scripts/scan-security` in CI (also wired into `committer` and the pre-commit hook). It is a deterministic, zero-dependency scanner for the attack classes documented against agent-instruction repos:

- **unicode-smuggling** — BIDI-override and zero-width characters (invisible instruction smuggling) in any file
- **curl-pipe-shell / base64-exec / opaque-blob** — download-and-execute and obfuscation patterns in any file
- **dynamic-preprocessing** — `` !`...` `` context injection in instruction files
- **steering-phrase** — agent-override or concealment phrasing ("ignore previous instructions", "without telling the user", "disable validation") in instruction files
- **credential-probe** — key-material paths and env-dump patterns in instruction files and helper scripts
- **network-in-helper** — network tools in helper scripts, enforcing the "helpers make no network calls" guarantee

Policy: findings block merge. Exceptions are never runtime flags — they are explicit `(check, path)` entries in the scanner's `ALLOWLIST`, land as reviewed code changes, and need a justification in the PR. Scanner exclusions (itself, `tests/` fixtures, `evals/results/` transcript data) are fixed in the scanner and documented here.

The second, non-automated layer: maintainers review contribution diffs with the repo's own [`agents/security-auditor.md`](agents/security-auditor.md) subagent (trace untrusted input to sinks, confirm exploitability before reporting) before merging changes to skills, agents, or tooling.
