#!/usr/bin/env bash
# Self-tests for the repo tooling. Builds throwaway fixture repos in a temp
# directory and asserts the validators, scaffolder, sync, and committer
# accept good input and reject bad input. No network, no dependencies
# beyond bash + python3 + git.
set -uo pipefail

script_dir=$(cd "$(dirname "$0")" && pwd)
repo_root=$(cd "$script_dir/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

passes=0
failures=0

expect_pass() {
  desc=$1
  shift
  if "$@" >/dev/null 2>&1; then
    passes=$((passes + 1))
    echo "PASS $desc"
  else
    failures=$((failures + 1))
    echo "FAIL $desc (expected success)"
  fi
}

expect_fail() {
  desc=$1
  shift
  if "$@" >/dev/null 2>&1; then
    failures=$((failures + 1))
    echo "FAIL $desc (expected failure)"
  else
    passes=$((passes + 1))
    echo "PASS $desc"
  fi
}

run_in_dir() {
  dir=$1
  shift
  (cd "$dir" && "$@")
}

skill_body() {
  # skill_body <name> — minimal body satisfying the house structure
  cat <<EOF
# $1

Intro sentence.

## When to use

- Situation.

## Workflow

1. Step.

## Pitfalls

- Trap.
EOF
}

write_skill() {
  # write_skill <root> <dir> <front-matter-name> <description-line>
  mkdir -p "$1/skills/$2"
  {
    printf -- '---\nname: %s\ndescription: %s\n---\n\n' "$3" "$4"
    skill_body "$3"
  } > "$1/skills/$2/SKILL.md"
}

# --- validate-skills: front matter ---

fixture="$tmp/good"
write_skill "$fixture" "good-skill" "good-skill" '"A valid description."'
expect_pass "valid skill passes" "$repo_root/scripts/validate-skills" "$fixture"

fixture="$tmp/mismatch"
write_skill "$fixture" "some-dir" "other-name" '"A valid description."'
expect_fail "name/directory mismatch fails" "$repo_root/scripts/validate-skills" "$fixture"

fixture="$tmp/unquoted"
write_skill "$fixture" "good-skill" "good-skill" 'Unquoted description here.'
expect_fail "unquoted description fails" "$repo_root/scripts/validate-skills" "$fixture"

fixture="$tmp/nodesc"
mkdir -p "$fixture/skills/no-desc"
{ printf -- '---\nname: no-desc\n---\n\n'; skill_body no-desc; } > "$fixture/skills/no-desc/SKILL.md"
expect_fail "missing description fails" "$repo_root/scripts/validate-skills" "$fixture"

fixture="$tmp/longdesc"
long_desc=$(printf 'a%.0s' {1..210})
write_skill "$fixture" "good-skill" "good-skill" "\"$long_desc\""
expect_fail "over-long description fails" "$repo_root/scripts/validate-skills" "$fixture"

fixture="$tmp/unknownkey"
mkdir -p "$fixture/skills/extra-key"
{
  printf -- '---\nname: extra-key\ndescription: "Valid."\nowner: "me"\n---\n\n'
  skill_body extra-key
} > "$fixture/skills/extra-key/SKILL.md"
expect_fail "unknown front matter key fails" "$repo_root/scripts/validate-skills" "$fixture"

fixture="$tmp/badcase"
write_skill "$fixture" "Bad_Case" "Bad_Case" '"A valid description."'
expect_fail "non-kebab-case name fails" "$repo_root/scripts/validate-skills" "$fixture"

fixture="$tmp/nofm"
mkdir -p "$fixture/skills/no-front"
printf -- '# Just a heading\n\nBody.\n' > "$fixture/skills/no-front/SKILL.md"
expect_fail "missing front matter fails" "$repo_root/scripts/validate-skills" "$fixture"

# --- validate-skills: body structure ---

fixture="$tmp/nobody"
mkdir -p "$fixture/skills/no-body"
printf -- '---\nname: no-body\ndescription: "Desc."\n---\n' > "$fixture/skills/no-body/SKILL.md"
expect_fail "empty body fails" "$repo_root/scripts/validate-skills" "$fixture"

fixture="$tmp/nosection"
mkdir -p "$fixture/skills/no-pitfalls"
printf -- '---\nname: no-pitfalls\ndescription: "Valid."\n---\n\n# no-pitfalls\n\n## When to use\n\n- X.\n\n## Workflow\n\n1. X.\n' \
  > "$fixture/skills/no-pitfalls/SKILL.md"
expect_fail "missing Pitfalls section fails" "$repo_root/scripts/validate-skills" "$fixture"

fixture="$tmp/badheading"
mkdir -p "$fixture/skills/wrong-head"
{
  printf -- '---\nname: wrong-head\ndescription: "Valid."\n---\n\n'
  skill_body other-title
} > "$fixture/skills/wrong-head/SKILL.md"
expect_fail "body heading not matching name fails" "$repo_root/scripts/validate-skills" "$fixture"

fixture="$tmp/longbody"
mkdir -p "$fixture/skills/long-body"
{
  printf -- '---\nname: long-body\ndescription: "Valid."\n---\n\n'
  skill_body long-body
  for i in {1..130}; do echo "- filler line $i"; done
} > "$fixture/skills/long-body/SKILL.md"
expect_fail "over-long body fails" "$repo_root/scripts/validate-skills" "$fixture"

fixture="$tmp/brokenlink"
write_skill "$fixture" "good-skill" "good-skill" '"A valid description."'
ln -s "$fixture/skills/does-not-exist" "$fixture/skills/dangling"
expect_fail "broken symlink skill fails" "$repo_root/scripts/validate-skills" "$fixture"

# --- validate-skills: helper scripts ---

fixture="$tmp/noexec"
write_skill "$fixture" "good-skill" "good-skill" '"A valid description."'
mkdir -p "$fixture/skills/good-skill/scripts"
printf -- '#!/usr/bin/env bash\necho hi\n' > "$fixture/skills/good-skill/scripts/helper.sh"
expect_fail "non-executable helper script fails" "$repo_root/scripts/validate-skills" "$fixture"
chmod +x "$fixture/skills/good-skill/scripts/helper.sh"
expect_pass "executable helper script passes" "$repo_root/scripts/validate-skills" "$fixture"
printf -- 'echo no shebang\n' > "$fixture/skills/good-skill/scripts/bad.sh"
chmod +x "$fixture/skills/good-skill/scripts/bad.sh"
expect_fail "helper script without shebang fails" "$repo_root/scripts/validate-skills" "$fixture"

# --- validate-docs ---

fixture="$tmp/docs-good"
mkdir -p "$fixture/docs"
cat > "$fixture/docs/thing.md" <<'EOF'
---
summary: "What this doc covers."
read_when: "When you need it."
---

# Thing
EOF
expect_pass "valid doc passes" "$repo_root/scripts/validate-docs" "$fixture"

fixture="$tmp/docs-bad"
mkdir -p "$fixture/docs"
printf -- '---\nsummary: "Only a summary."\n---\n\n# Thing\n' > "$fixture/docs/thing.md"
expect_fail "doc missing read_when fails" "$repo_root/scripts/validate-docs" "$fixture"

# --- validate-links ---

fixture="$tmp/links-good"
mkdir -p "$fixture/docs"
printf -- 'hello\n' > "$fixture/docs/other.md"
cat > "$fixture/docs/a.md" <<'EOF'
See [real](other.md), [up](../top.md), [ext](https://example.com), [anchor](#x).

```
[fenced links are ignored](nowhere.md)
```
EOF
printf -- 'top\n' > "$fixture/top.md"
expect_pass "valid relative links pass" "$repo_root/scripts/validate-links" "$fixture"

fixture="$tmp/links-bad"
mkdir -p "$fixture"
printf -- 'See [dead](missing.md).\n' > "$fixture/x.md"
expect_fail "dead relative link fails" "$repo_root/scripts/validate-links" "$fixture"

# --- new-skill ---

fixture="$tmp/scaffold"
mkdir -p "$fixture/skills"
expect_pass "new-skill scaffolds a valid skill" \
  "$repo_root/scripts/new-skill" --root "$fixture" fresh-skill "A scaffolded description."
expect_pass "scaffolded skill validates" "$repo_root/scripts/validate-skills" "$fixture"
expect_fail "new-skill refuses duplicates" \
  "$repo_root/scripts/new-skill" --root "$fixture" fresh-skill "Again."
expect_fail "new-skill refuses bad names" \
  "$repo_root/scripts/new-skill" --root "$fixture" "Bad Name" "Desc."
expect_pass "new-skill preserves special characters" \
  "$repo_root/scripts/new-skill" --root "$fixture" amp-skill "Fast & safe a/b scaffolding."
expect_pass "special characters land verbatim in front matter" \
  grep -qF 'description: "Fast & safe a/b scaffolding."' "$fixture/skills/amp-skill/SKILL.md"
expect_fail "new-skill rejects double quotes in description" \
  "$repo_root/scripts/new-skill" --root "$fixture" quote-skill 'A "quoted" description.'

# --- committer ---

gitfx="$tmp/gitrepo"
mkdir -p "$gitfx"
git -C "$gitfx" init -q
git -C "$gitfx" config user.email test@example.com
git -C "$gitfx" config user.name "Test Runner"
echo hi > "$gitfx/file.txt"
expect_fail "committer rejects non-conventional message" \
  run_in_dir "$gitfx" "$repo_root/scripts/committer" -m "update stuff" file.txt
long_subject="feat: $(printf 'x%.0s' {1..80})"
expect_fail "committer rejects over-long subject" \
  run_in_dir "$gitfx" "$repo_root/scripts/committer" -m "$long_subject" file.txt
expect_pass "committer commits the exact file" \
  run_in_dir "$gitfx" "$repo_root/scripts/committer" -m "feat: add file" file.txt
expect_pass "commit exists after committer" git -C "$gitfx" rev-parse HEAD
echo a > "$gitfx/a.txt"
echo b > "$gitfx/b.txt"
git -C "$gitfx" add a.txt
expect_fail "committer refuses when unrelated files are staged" \
  run_in_dir "$gitfx" "$repo_root/scripts/committer" -m "feat: add b" b.txt

# --- validate-skills: security lint ---

fixture="$tmp/dynshell"
mkdir -p "$fixture/skills/dyn-shell"
{
  printf -- '---\nname: dyn-shell\ndescription: "Valid."\n---\n\n'
  skill_body dyn-shell
  printf -- '\nInject: !%s\n' '`git diff`'
} > "$fixture/skills/dyn-shell/SKILL.md"
expect_fail "dynamic shell preprocessing in skill body fails" \
  "$repo_root/scripts/validate-skills" "$fixture"

# --- validate-agents ---

agent_file() {
  # agent_file <path> <name> [model]
  cat > "$1" <<EOF
---
name: $2
description: Does well-specified helper work.
model: ${3:-haiku}
tools: Read, Grep
---

You are a helper.

## Output contract

Report exactly what you did.
EOF
}

fixture="$tmp/agents-good"
mkdir -p "$fixture/agents"
agent_file "$fixture/agents/helper-bot.md" helper-bot
expect_pass "valid agent passes" "$repo_root/scripts/validate-agents" "$fixture"

fixture="$tmp/agents-mismatch"
mkdir -p "$fixture/agents"
agent_file "$fixture/agents/wrong-file.md" helper-bot
expect_fail "agent name/file mismatch fails" "$repo_root/scripts/validate-agents" "$fixture"

fixture="$tmp/agents-badmodel"
mkdir -p "$fixture/agents"
agent_file "$fixture/agents/helper-bot.md" helper-bot gpt-4
expect_fail "unknown agent model fails" "$repo_root/scripts/validate-agents" "$fixture"

fixture="$tmp/agents-nocontract"
mkdir -p "$fixture/agents"
printf -- '---\nname: no-contract\ndescription: Valid.\n---\n\nYou are a helper.\n' \
  > "$fixture/agents/no-contract.md"
expect_fail "agent without output contract fails" "$repo_root/scripts/validate-agents" "$fixture"

fixture="$tmp/agents-unknownkey"
mkdir -p "$fixture/agents"
printf -- '---\nname: extra\ndescription: Valid.\nsecret_hook: x\n---\n\nBody.\n\n## Output contract\n\nReport.\n' \
  > "$fixture/agents/extra.md"
expect_fail "agent with unknown front matter key fails" "$repo_root/scripts/validate-agents" "$fixture"

expect_pass "missing agents dir passes" "$repo_root/scripts/validate-agents" "$tmp/good"

# --- validate-plugin ---

fixture="$tmp/plugin-bad"
mkdir -p "$fixture/.claude-plugin"
printf -- '{"name": "x-plugin", "plugins": [{"name": "x-plugin"}]}\n' \
  > "$fixture/.claude-plugin/marketplace.json"
expect_fail "marketplace missing owner and source fails" \
  "$repo_root/scripts/validate-plugin" "$fixture"

fixture="$tmp/plugin-badsource"
mkdir -p "$fixture/.claude-plugin"
printf -- '{"name": "x", "owner": {"name": "y"}, "plugins": [{"name": "x", "source": "./missing-dir"}]}\n' \
  > "$fixture/.claude-plugin/marketplace.json"
expect_fail "marketplace source pointing nowhere fails" \
  "$repo_root/scripts/validate-plugin" "$fixture"

fixture="$tmp/plugin-json"
mkdir -p "$fixture/.claude-plugin"
printf -- 'not json{\n' > "$fixture/.claude-plugin/plugin.json"
expect_fail "malformed plugin JSON fails" "$repo_root/scripts/validate-plugin" "$fixture"

expect_pass "no .claude-plugin dir passes" "$repo_root/scripts/validate-plugin" "$tmp/good"

# --- sync-skills ---

fixture="$tmp/sync"
export CLAUDE_SKILLS_DIR="$fixture/claude-skills"
export CODEX_SKILLS_DIR="$fixture/codex-skills"
expect_pass "sync-skills links this repo's skills" "$repo_root/scripts/sync-skills"
expect_pass "claude link created" test -L "$CLAUDE_SKILLS_DIR/debug-loop"
expect_pass "codex root link created" test -L "$CODEX_SKILLS_DIR/agents-scripts"
before=$(find "$CLAUDE_SKILLS_DIR" -type l | wc -l)
"$repo_root/scripts/sync-skills" >/dev/null 2>&1
after=$(find "$CLAUDE_SKILLS_DIR" -type l | wc -l)
expect_pass "sync-skills is idempotent" test "$before" = "$after"
unset CLAUDE_SKILLS_DIR CODEX_SKILLS_DIR

# --- the repo itself must validate ---

expect_pass "this repo's skills validate" "$repo_root/scripts/validate-skills"
expect_pass "this repo's docs validate" "$repo_root/scripts/validate-docs"
expect_pass "this repo's agents validate" "$repo_root/scripts/validate-agents"
expect_pass "this repo's plugin packaging validates" "$repo_root/scripts/validate-plugin"
expect_pass "this repo's links resolve" "$repo_root/scripts/validate-links"

echo
echo "tests: $passes passed, $failures failed"
[ "$failures" -eq 0 ]
