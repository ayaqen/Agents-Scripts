#!/usr/bin/env bash
# Print a fast structural map of a repository: layout, file census,
# entry points, and recent churn. Read-only.
#
# Usage: repo-map.sh [path] (default: current directory)
# No -e: pipelines here end in `head`, and upstream SIGPIPE on large repos
# is expected, not an error. This script only reports; it never mutates.
set -uo pipefail

root=${1:-.}
cd "$root" || exit 1

echo "== Top-level layout =="
ls -1 | head -30

echo
echo "== File census (top 10 extensions) =="
git ls-files 2>/dev/null | awk -F. 'NF>1 {print $NF}' | sort | uniq -c | sort -rn | head -10

echo
echo "== Entry points / manifests =="
for f in package.json pyproject.toml setup.py Cargo.toml go.mod Makefile \
  justfile Gemfile pom.xml build.gradle CMakeLists.txt Dockerfile \
  docker-compose.yml; do
  [ -f "$f" ] && echo "  $f"
done
if [ -d .github/workflows ]; then
  echo "  CI workflows:"
  ls .github/workflows | sed 's/^/    /'
fi

echo
echo "== Hot files (most commits, last 90 days) =="
git log --since="90 days ago" --name-only --pretty=format: 2>/dev/null |
  grep -v '^$' | sort | uniq -c | sort -rn | head -15

echo
echo "== Largest tracked source files =="
git ls-files 2>/dev/null | while IFS= read -r f; do
  [ -f "$f" ] && wc -l "$f" 2>/dev/null
done | sort -rn | head -10
