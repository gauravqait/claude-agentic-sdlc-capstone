# Hook tests (T8)
Run from repo root in Git Bash. Each case feeds hook input JSON on stdin and expects the exit code shown. No real token is stored: the fake one is built at run time.

```bash
G=$(pwd)/.claude/hooks/pipeline-guard.sh; S=$(pwd)/.claude/hooks/check-secrets.sh
FAKE="ghp_$(printf 'a%.0s' $(seq 24))"
t(){ echo "$2" | bash "$3" >/dev/null 2>/tmp/err; c=$?; [ "$c" = "$4" ] && r=PASS || r=FAIL; echo "$r  $1 (exit $c, want $4) $(head -c 80 /tmp/err)"; }

# Fixture: steps 1-4 approved, 5-8 pending (live state file is never read)
F=$(mktemp -d); mkdir -p $F/docs/KAN-4; { echo "{"; for i in 1 2 3 4 5 6 7 8; do st=pending; [ $i -le 4 ] && st=approved; echo "\"$i\": {\"agent\": \"0$i-x.agent.md\", \"status\": \"$st\"},"; done; echo "\"end\": 0}"; } > $F/docs/KAN-4/pipeline-state.json
(cd $F
t "H1 skipped step (06 while 05 not approved)" '{"tool_name":"Agent","tool_input":{"subagent_type":"06-code-review","prompt":"KAN-4"}}' $G 2
t "H1b next step allowed (05 while 04 approved)" '{"tool_name":"Agent","tool_input":{"subagent_type":"05-implementation"}}' $G 0)
t "H2 subagent writes state file (any content)" '{"tool_name":"Edit","agent_id":"abc","tool_input":{"file_path":"docs/KAN-4/pipeline-state.json","new_string":"x"}}' $G 2
t "H2c orchestrator writes state file" '{"tool_name":"Edit","tool_input":{"file_path":"docs/KAN-4/pipeline-state.json","new_string":"x"}}' $G 0
t "H3 secret in context file" "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"context/workflow-context.json\",\"content\":\"$FAKE\"}}" $S 2
t "H3b clean context file" '{"tool_name":"Write","tool_input":{"file_path":"context/workflow-context.json","content":"{}"}}' $S 0

# H4 commit/push on main (temp repo on main), then on a feature branch
N=$(pwd)/.claude/hooks/no-main-commit.sh; D=$(mktemp -d); (cd $D && git init -q -b main
 t "H4 git commit on main" '{"tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' $N 2
 t "H4b git push on main" '{"tool_name":"Bash","tool_input":{"command":"git push origin main"}}' $N 2
 t "H4d git -C dir commit on main" '{"tool_name":"Bash","tool_input":{"command":"git -C . commit -m x"}}' $N 2
 t "H4e git -c k=v commit on main" '{"tool_name":"Bash","tool_input":{"command":"git -c user.name=a commit -m x"}}' $N 2
 git checkout -q -b feature/kan-4-x
 t "H4c commit on feature branch" '{"tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' $N 0)
```
