#!/usr/bin/env bash
# PreToolUse hook (Write|Edit): block any file write (docs, context, code) that contains a token.
# Patterns: GitHub (ghp_ gho_ ghs_ github_pat_), AWS key id, Atlassian ATATT, Bearer token, PEM private key header.
input=$(cat)
if echo "$input" | grep -Eq 'ghp_[A-Za-z0-9]{20,}|gho_[A-Za-z0-9]{20,}|ghs_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|ATATT[A-Za-z0-9_=-]{20,}|Bearer [A-Za-z0-9._~+/=-]{20,}|-----BEGIN [A-Z ]*PRIVATE KEY'; then
  echo "Blocked: content looks like a secret token. Use an environment variable instead." >&2
  exit 2
fi
exit 0
