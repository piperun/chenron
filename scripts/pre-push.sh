#!/bin/sh
set -e

# Recursion guard — this script pushes tags, which triggers pre-push again
[ "$CHENRON_PUSHING_TAGS" = "1" ] && exit 0

REMOTE="$1"

# Read stdin to detect whether the parent `git push` already includes tag
# refs. If it does, our own tag-push below would race with it: the parent
# ends up rejecting tags as "already exists" (because we just pushed them),
# and atomic-push semantics then reject the branch too. Push tags only
# when the parent is branch-only.
PUSHING_TAGS=0
while read -r _local_ref _local_sha remote_ref _remote_sha; do
  case "$remote_ref" in
    refs/tags/*) PUSHING_TAGS=1 ;;
  esac
done

# Promote any local lightweight release tags to annotated before pushing.
# cog 7.x's `--auto` bump leaves per-package tags lightweight even when
# called with `-A "v{{version}}"`, which can prevent GitHub Actions release
# workflows from firing and causes 1970-01-01 dates in changelogs.
#
# Match release tags by the `v<digit>` segment to avoid touching ad-hoc
# lightweight tags (e.g. `wip-foo`). Annotation message follows cog's
# `v{{version}}` convention (e.g. `chenron-v1.10.0` -> `v1.10.0`).
for tag in $(git tag -l '*v[0-9]*'); do
  # Skip if already on remote (tags are immutable once pushed).
  if git ls-remote --tags "$REMOTE" "refs/tags/$tag" 2>/dev/null | grep -q .; then
    continue
  fi
  # Skip if already annotated. cat-file type "tag" = annotated; "commit" = lightweight.
  type=$(git cat-file -t "$tag" 2>/dev/null || echo "")
  if [ "$type" = "tag" ]; then
    continue
  fi
  COMMIT=$(git rev-parse "$tag^{commit}" 2>/dev/null || echo "")
  if [ -z "$COMMIT" ]; then
    echo "=> Warning: could not resolve commit for tag '$tag'; skipping" >&2
    continue
  fi
  # Strip everything up through `-v` so `chenron-v1.10.0` -> `v1.10.0`,
  # while a bare `v1.1.0` (global tag) stays as-is.
  msg=$(echo "$tag" | sed -E 's/.*-v/v/')
  echo "=> Promoting lightweight tag '$tag' to annotated ($msg)"
  git tag -d "$tag" >/dev/null
  git tag -a "$tag" "$COMMIT" -m "$msg"
done

# Parent push already covers tags; don't double-push from here.
if [ "$PUSHING_TAGS" = "1" ]; then
  exit 0
fi

# Find local tags not on the remote
UNPUSHED=$(git tag -l | while read -r tag; do
  git ls-remote --tags "$REMOTE" "refs/tags/$tag" 2>/dev/null | grep -q . || echo "$tag"
done)

if [ -n "$UNPUSHED" ]; then
  echo "=> Pushing tags: $(echo $UNPUSHED | tr '\n' ' ')"
  CHENRON_PUSHING_TAGS=1 git push "$REMOTE" --tags
fi
