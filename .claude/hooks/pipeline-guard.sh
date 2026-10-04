#!/usr/bin/env bash
# PreToolUse hook. Two checks, exit 2 blocks the call.
#  1. Write|Edit: a subagent may not touch pipeline-state.json.
#  2. Agent: step N may start only if step N-1 is approved (steps 02-08).
input=$(cat)
has() { echo "$input" | grep -qE "$1"; }
block() { echo "Blocked: $1" >&2; exit 2; }

# 1. Subagent writing the state file (hook input has "agent_id" only for subagents)
if has '"tool_name"[[:space:]]*:[[:space:]]*"(Write|Edit)"'; then
  has 'pipeline-state\.json' && has '"agent_id"' && block "subagents must not edit pipeline-state.json."
  exit 0
fi

# 2. Step order: which step is starting?
agent=$(echo "$input" | sed -n 's/.*"subagent_type"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
case "$agent" in 0[2-8]-*) ;; *) exit 0 ;; esac

# Find its state file: story ID in the prompt, else the only state file
story=$(echo "$input" | grep -oE '[A-Z][A-Z0-9]+-[0-9]+' | while read -r id; do [ -f "docs/$id/pipeline-state.json" ] && echo "$id" && break; done)
if [ -n "$story" ]; then state="docs/$story/pipeline-state.json"
elif [ "$(ls docs/*/pipeline-state.json 2>/dev/null | wc -l)" = 1 ]; then state=$(ls docs/*/pipeline-state.json)
else block "cannot tell which docs/<STORY-ID>/pipeline-state.json applies."; fi

# Previous step must be approved
prev=$(printf '%02d' $((10#${agent%%-*} - 1)))
prev_name=$(grep -o "\"$prev-[a-z.-]*\"" "$state" | head -1 | tr -d '"')
grep -A3 "\"$prev_name\"" "$state" | grep -q '"status"[[:space:]]*:[[:space:]]*"approved"' \
  || block "step $prev_name is not approved yet."
exit 0
