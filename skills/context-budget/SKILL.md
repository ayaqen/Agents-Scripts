---
name: context-budget
description: "Work in large codebases without drowning context: targeted reads, delegated searches, externalized state."
---

# context-budget

Context is the scarcest resource in an agent session. Every file dumped into it displaces reasoning. This skill is about spending reads like money.

## When to use

- The codebase is far larger than one context window.
- A long multi-step task where mid-task amnesia would be costly.
- You notice re-reading files you've already read — that's the budget leaking.

## Workflow

1. **Search before reading.** Locate the target with grep/glob first; read only the matching region of a file, not the whole file. A 3,000-line file usually owes you 40 relevant lines.
2. **Delegate sweeps.** When answering requires scanning many files, hand the sweep to a subagent that returns a conclusion, keeping the raw file contents out of your context. Keep only the answer.
3. **Externalize state early.** Maintain a running notes file (scratchpad or `HANDOFF.md`) with decisions made, files touched, and commands that prove progress. Update it as you go, not at the end — context can end without warning.
4. **Batch related questions** against a file so you read it once. Before opening a file, know what you're asking it.
5. **Don't cache what the repo remembers for you.** Line numbers, exact signatures, and directory listings can be re-derived cheaply; conclusions and decisions cannot — keep the latter, drop the former.
6. Nearing exhaustion → switch to `session-handoff` while you still have room to write a good one.

## Pitfalls

- "Read the whole file for context" as a habit. Whole-file reads are a tool for small files and final reviews, not exploration.
- Pasting large tool outputs (test logs, diffs) into notes verbatim. Summarize the finding; reference the command that regenerates the raw output.
- Spending the last 10% of context on work instead of on the handoff that preserves the other 90%.
