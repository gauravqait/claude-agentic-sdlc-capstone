#!/usr/bin/env bash
# PreToolUse hook.
#  - Write|Edit on pipeline-state.json by a subagent (input has "agent_id") is blocked.
#  - Agent|Task: a step may start only if the previous step is approved.
input=$(cat)
tool=$(echo "$input" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"\(.*\)"/\1/')

if [ "$tool" = "Write" ] || [ "$tool" = "Edit" ]; then
  if echo "$input" | grep -q 'pipeline-state\.json' && echo "$input" | grep -q '"agent_id"'; then
    echo "Blocked: subagents must not edit pipeline-state.json; the orchestrator does." >&2
    exit 2
  fi
  exit 0
fi

agent=$(echo "$input" | sed -n 's/.*"subagent_type"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
case "$agent" in 0[2-8]-*) ;; *) exit 0 ;; esac   # guard steps 02-08 only

# State file: the story named in the prompt, else the only existing one.
story=$(echo "$input" | grep -oE '[A-Z][A-Z0-9]+-[0-9]+' | while read -r id; do [ -f "docs/$id/pipeline-state.json" ] && echo "$id" && break; done)
if [ -n "$story" ]; then state="docs/$story/pipeline-state.json"
elif [ "$(ls docs/*/pipeline-state.json 2>/dev/null | wc -l)" = 1 ]; then state=$(ls docs/*/pipeline-state.json)
else echo "Blocked: cannot tell which docs/<STORY-ID>/pipeline-state.json applies." >&2; exit 2; fi

prev=$(printf '%02d' $((10#${agent%%-*} - 1)))
prev_name=$(grep -o "\"$prev-[a-z.-]*\"" "$state" | head -1 | tr -d '"')
if ! grep -A3 "\"$prev_name\"" "$state" | grep -q '"status"[[:space:]]*:[[:space:]]*"approved"'; then
  echo "Blocked: step $prev_name is not approved yet." >&2
  exit 2
fi
exit 0
