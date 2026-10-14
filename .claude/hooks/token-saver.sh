#!/usr/bin/env bash
# PreToolUse hook (Read): keep wasteful reads out of the context window. Exit 2 blocks the call.
#  1. Vendored/generated paths, lockfiles, binary and minified files are never useful to read.
#  2. A large file read without "limit" is blocked; retry with offset/limit or use Grep.
# Override the size cap (bytes) with TOKEN_SAVER_MAX_BYTES; disable with TOKEN_SAVER=off.
[ "$TOKEN_SAVER" = "off" ] && exit 0
input=$(cat)
block() { echo "Blocked (token-saver): $1" >&2; exit 2; }

printf "%s" "$input" | grep -qE '"tool_name"[[:space:]]*:[[:space:]]*"Read"' || exit 0

# JSON-escaped Windows path (C:\\Users\\x) -> forward slashes, which Git Bash accepts
path=$(printf "%s" "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1 | sed 's#\\\\#/#g')
[ -n "$path" ] || exit 0

printf "%s" "$path" | grep -qE '(^|/)(node_modules|\.git|coverage)/' \
  && block "$path is vendored/generated content. Search it with Grep for the exact symbol instead."
printf "%s" "$path" | grep -qiE '(package-lock\.json|yarn\.lock|pnpm-lock\.yaml)$' \
  && block "$path is a lockfile. Use Grep for the specific package."
printf "%s" "$path" | grep -qiE '\.(docx|xlsx|pptx|zip|gz|tar|exe|dll|min\.js|min\.css|map)$' \
  && block "$path is a binary or minified file that cannot be read usefully as text."

# Large file with no limit: ~4 bytes per token, so 100000 bytes is about 25k tokens
printf "%s" "$input" | grep -qE '"limit"[[:space:]]*:' && exit 0
[ -f "$path" ] || exit 0
size=$(wc -c < "$path" | tr -d '[:space:]')
max=${TOKEN_SAVER_MAX_BYTES:-100000}
[ "$size" -gt "$max" ] \
  && block "$path is $size bytes (~$((size / 4)) tokens). Re-run Read with offset and limit, or use Grep to locate the part you need."
exit 0
