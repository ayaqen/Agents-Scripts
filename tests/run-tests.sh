#!/usr/bin/env bash
# Self-tests for the repo tooling. Builds throwaway fixture repos in a temp
# directory and asserts the validators and scaffolder accept good input and
# reject bad input. No network, no dependencies beyond bash + python3.
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

write_skill() {
  # write_skill <root> <dir> <front-matter-name> <description-line>
  mkdir -p "$1/skills/$2"
  cat > "$1/skills/$2/SKILL.md" <<EOF
---
name: $3
description: $4
---

# $3

A body with actual content.
EOF
}

# --- validate-skills ---

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
printf -- '---\nname: no-desc\n---\n\nBody.\n' > "$fixture/skills/no-desc/SKILL.md"
expect_fail "missing description fails" "$repo_root/scripts/validate-skills" "$fixture"

fixture="$tmp/nobody"
mkdir -p "$fixture/skills/no-body"
printf -- '---\nname: no-body\ndescription: "Desc."\n---\n' > "$fixture/skills/no-body/SKILL.md"
expect_fail "empty body fails" "$repo_root/scripts/validate-skills" "$fixture"

fixture="$tmp/badcase"
write_skill "$fixture" "Bad_Case" "Bad_Case" '"A valid description."'
expect_fail "non-kebab-case name fails" "$repo_root/scripts/validate-skills" "$fixture"

fixture="$tmp/nofm"
mkdir -p "$fixture/skills/no-front"
printf -- '# Just a heading\n\nBody.\n' > "$fixture/skills/no-front/SKILL.md"
expect_fail "missing front matter fails" "$repo_root/scripts/validate-skills" "$fixture"

fixture="$tmp/brokenlink"
write_skill "$fixture" "good-skill" "good-skill" '"A valid description."'
ln -s "$fixture/skills/does-not-exist" "$fixture/skills/dangling"
expect_fail "broken symlink skill fails" "$repo_root/scripts/validate-skills" "$fixture"

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

echo
echo "tests: $passes passed, $failures failed"
[ "$failures" -eq 0 ]
