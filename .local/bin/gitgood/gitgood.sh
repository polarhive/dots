#!/usr/bin/env bash
set -euo pipefail
if ! command -v fzf >/dev/null; then
  echo "fzf not installed. Install it first." >&2
  exit 1
fi

RESULT=$(cat users.txt | fzf -i)
AUTHOR_NAME=$(echo "$RESULT" | cut -d ',' -f 1)
AUTHOR_EMAIL=$(echo "$RESULT" | cut -d ',' -f 2)

COMMIT_DATE=$(cat dates.txt | fzf -i)
AUTHOR_DATE=$COMMIT_DATE

echo "$COMMIT_DATE"
echo "$AUTHOR_DATE"
echo "$AUTHOR_EMAIL"
echo "$AUTHOR_NAME"

# Apply metadata (author = committer)
export GIT_AUTHOR_NAME="$AUTHOR_NAME"
export GIT_AUTHOR_EMAIL="$AUTHOR_EMAIL"
export GIT_AUTHOR_DATE="$COMMIT_DATE"
export GIT_COMMITTER_NAME="$AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$AUTHOR_EMAIL"
export GIT_COMMITTER_DATE="$COMMIT_DATE"

git commit --author="$AUTHOR_NAME <$AUTHOR_EMAIL>"

echo "Commit created:"
echo "Author:   $AUTHOR_NAME <$AUTHOR_EMAIL>"
echo "Date:     $COMMIT_DATE"
git log -1
