#!/bin/sh
set -e

# Recursion guard — this script pushes tags, which triggers pre-push again
[ "$CHENRON_PUSHING_TAGS" = "1" ] && exit 0

REMOTE="$1"

# Find local tags not on the remote
UNPUSHED=$(git tag -l | while read -r tag; do
  git ls-remote --tags "$REMOTE" "refs/tags/$tag" 2>/dev/null | grep -q . || echo "$tag"
done)

if [ -n "$UNPUSHED" ]; then
  echo "=> Pushing tags: $(echo $UNPUSHED | tr '\n' ' ')"
  CHENRON_PUSHING_TAGS=1 git push "$REMOTE" --tags
fi
