#!/usr/bin/env bash
# PreToolUse hook (Write|Edit): block any file write (docs, context, code) that contains a token.
input=$(cat)
if echo "$input" | grep -Eq 'ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}'; then
  echo "Blocked: content looks like a secret token. Use an environment variable instead." >&2
  exit 2
fi
exit 0
