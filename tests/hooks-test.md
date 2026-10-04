# Hook tests
Run from the repo root in Git Bash. Each command feeds a hook one tool call and prints its exit code: `2` = blocked, `0` = allowed.

## 1. check-secrets.sh
```bash
H=.claude/hooks
FAKE="ghp_$(printf 'a%.0s' $(seq 24))"
echo '{"tool_name":"Write","tool_input":{"content":"'$FAKE'"}}' | bash $H/check-secrets.sh; echo "want 2: $?"
echo '{"tool_name":"Write","tool_input":{"content":"hello"}}'    | bash $H/check-secrets.sh; echo "want 0: $?"
```

## 2. no-main-commit.sh
```bash
H=$(pwd)/.claude/hooks; cd $(mktemp -d) && git init -q -b main
echo '{"tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' | bash $H/no-main-commit.sh; echo "want 2: $?"
git checkout -q -b feature/abc-1-x
echo '{"tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' | bash $H/no-main-commit.sh; echo "want 0: $?"
```

## 3. pipeline-guard.sh
Steps 1-4 approved, 5-8 pending.
```bash
H=$(pwd)/.claude/hooks; cd $(mktemp -d) && mkdir -p docs/ABC-1
for i in 1 2 3 4 5 6 7 8; do s=pending; [ $i -le 4 ] && s=approved; echo "\"0$i-x\": {\"status\": \"$s\"},"; done > docs/ABC-1/pipeline-state.json
echo '{"tool_name":"Agent","tool_input":{"subagent_type":"06-code-review"}}'   | bash $H/pipeline-guard.sh; echo "want 2: $?"
echo '{"tool_name":"Agent","tool_input":{"subagent_type":"05-implementation"}}' | bash $H/pipeline-guard.sh; echo "want 0: $?"
echo '{"tool_name":"Edit","agent_id":"a","tool_input":{"file_path":"docs/ABC-1/pipeline-state.json"}}' | bash $H/pipeline-guard.sh; echo "want 2: $?"
echo '{"tool_name":"Edit","tool_input":{"file_path":"docs/ABC-1/pipeline-state.json"}}'                | bash $H/pipeline-guard.sh; echo "want 0: $?"
```
