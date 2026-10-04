# Gate tests (KAN-5 AC 11)
Run from the repo root in Git Bash. Blocked-start and state-write cases run the real hook (also in `tests/hooks-test.md` section 3); the orchestrator rules are checked as written.

## 1. Happy order and blocked start (pipeline-guard.sh)
```bash
H=$(pwd)/.claude/hooks; cd $(mktemp -d) && mkdir -p docs/ABC-1
mk() { for i in 1 2 3 4 5 6 7 8; do s=pending; [ $i -le $1 ] && s=approved; echo "\"0$i-x\": {\"status\": \"$s\"},"; done > docs/ABC-1/pipeline-state.json; }
mk 2
echo '{"tool_name":"Agent","tool_input":{"subagent_type":"03-x","prompt":"ABC-1"}}' | bash $H/pipeline-guard.sh; echo "want 0 (prior approved): $?"
echo '{"tool_name":"Agent","tool_input":{"subagent_type":"04-x","prompt":"ABC-1"}}' | bash $H/pipeline-guard.sh; echo "want 2 (prior not approved): $?"
sed -i 's/"02-x": {"status": "approved"}/"02-x": {"status": "awaiting_approval"}/' docs/ABC-1/pipeline-state.json
echo '{"tool_name":"Agent","tool_input":{"subagent_type":"03-x","prompt":"ABC-1"}}' | bash $H/pipeline-guard.sh; echo "want 2 (awaiting_approval is not approved): $?"
```

## 2. Subagent cannot write the state file
Run in the same shell as section 1 (uses `$H`).
```bash
echo '{"tool_name":"Write","agent_id":"a","tool_input":{"file_path":"docs/ABC-1/pipeline-state.json"}}' | bash $H/pipeline-guard.sh; echo "want 2: $?"
```

## 3. No loop-back, 2-rejection limit, step 8 approval are written
```bash
R=.claude/rules/workflow-state.md; C=.claude/commands/run-sdlc-workflow.md
grep -c 'There is no loop back to an earlier step' $R | sed 's/^/want 1: /'
grep -c 'After 2 rejections of one step the orchestrator asks the user' $R | sed 's/^/want 1: /'
grep -c 'Step 8 (PR) needs explicit user approval' $R | sed 's/^/want 1: /'
grep -c 'Start step N+1 only when step N is `approved`' $C | sed 's/^/want 1: /'
grep -c 'Step 8b (PR creation) needs explicit user approval' $C | sed 's/^/want 1: /'
```
