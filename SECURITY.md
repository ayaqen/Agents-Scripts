# Security Policy

This repo ships agent instructions and dependency-free shell/python tooling — no runtime services, no third-party packages. The surfaces that matter:

- **Scripts run on contributor machines.** Report anything that could make `sync-skills`, `committer`, or the validators destructive or injectable (e.g. crafted file names, descriptions, or front matter reaching a shell).
- **Skills are followed by AI agents.** Report skill content that could steer an agent into unsafe behavior: secret exfiltration, destructive git operations, or prompt-injection vectors.
- **CI workflow changes.** The workflow runs with read-only permissions; report anything that would escalate them.

Report privately via GitHub Security Advisories ("Report a vulnerability" on this repository) and include a reproduction. Please do not open public issues for suspected vulnerabilities.
