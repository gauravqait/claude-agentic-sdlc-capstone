#!/usr/bin/env bash
# PreToolUse hook (Bash): block `git commit` and `git push` while the current branch is main.
input=$(cat)
echo "$input" | grep -Eq 'git([[:space:]]+-[cC][[:space:]]+[^[:space:]]+)*[[:space:]]+(commit|push)' || exit 0
branch=$(git branch --show-current 2>/dev/null)
if [ "$branch" = "main" ]; then
  echo "Blocked: git commit/push on main. Use a feature/<story-id>-<slug> branch." >&2
  exit 2
fi
exit 0
