---
name: security-review
description: "Security pass over a diff, feature, or dependency: trace untrusted input, verify exploitability, fix the sink."
---

# security-review

An adversarial read of a change — think like an attacker who already has the diff in hand. This is defensive review of code you're authorized to audit, not a pentest of a system you don't own. The deliverable is confirmed, fixable findings, not a grep dump of scary-looking function names.

## When to use

- Changes touching input handling, auth, secrets, network calls, file paths, subprocess/exec, or deserialization.
- Before merging any PR that touches the above.
- Adopting a new dependency — pair with the sibling skill `dependency-vet` for the supply-chain side.

## Workflow

1. Map trust boundaries in the change: list every place untrusted data enters — user input, network responses, file contents, environment, and LLM/tool output.
2. Trace each untrusted path forward to its sink. Check the classics: injection (SQL, shell, path traversal, template), unsafe deserialization, SSRF, XSS, missing authn/authz on new endpoints, TOCTOU races.
3. Secrets discipline: nothing hardcoded, logged, or committed; error paths don't leak internals (stack traces, file paths, versions) to users.
4. LLM-specific surfaces, when present: retrieved or tool-returned content can carry prompt injection — treat it as untrusted input. Model output used in privileged operations (shell, SQL, URLs) needs the same validation as any other untrusted string.
5. Confirm exploitability before reporting: construct the concrete malicious input that reaches the sink. A finding you can't demonstrate is a hypothesis, not a vulnerability — label it as such.
6. Report each confirmed finding with severity (impact × likelihood), the demonstrating input, and a fix that targets the sink, not the call site.
7. Land fixes with a regression test that encodes the attack input, so the sink stays closed.

## Pitfalls

- Pattern-grepping without tracing reachability — unreproducible findings erode trust in the whole review.
- Reporting "no issues found" when you mean "no issues in what I checked" — state the checked surface explicitly.
- Trusting input because "it comes from us" — trust boundaries move over time, and defense in depth exists for exactly this reason.
- Sanitizing one call site instead of fixing the sink — the next caller reintroduces the bug.
- Letting severity inflation (everything critical) or deflation (everything a nit) replace honest triage.
