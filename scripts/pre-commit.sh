#!/bin/sh
set -e

STAGED=$(git diff --cached --name-only --diff-filter=d)
tested=0

for pkg in packages/database packages/cache_manager packages/basedir packages/vibe packages/web_archiver apps/chenron; do
  if echo "$STAGED" | grep -q "^${pkg}/"; then
    if [ -d "${pkg}/test" ]; then
      echo "=> Running tests for ${pkg}"
      flutter test "$pkg" || exit 1
      tested=$((tested + 1))
    fi
  fi
done

if [ "$tested" -gt 0 ]; then
  echo "Pre-commit: $tested package(s) tested, all passed."
fi
