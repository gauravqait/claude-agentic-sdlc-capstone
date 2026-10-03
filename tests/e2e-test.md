# E2E dry-run checks (T9)
Static checks only: no Jira call, no agent run. Run from repo root in Git Bash.

```bash
ID_RE='^[A-Z][A-Z0-9]+-[0-9]+$'
for id in KAN-4 kan4 "" "KAN-"; do [[ "$id" =~ $ID_RE ]] && echo "E1 '$id' -> accepted" || echo "E1 '$id' -> stop: Invalid story ID"; done
# E2 context has Not Found / ACs
grep -c '"acceptanceCriteria"' context/workflow-context.json
# E3 artifacts: a step is complete only if its file exists and is non-empty
for f in 01-requirements 02-architecture 03-design-review 04-impl-plan 05-implementation-summary 06-code-review 07-verification-report 08-pr-summary; do
  [ -s docs/KAN-4/$f.md ] && echo "OK      $f.md" || echo "MISSING $f.md"; done
# E4 every agent 01-07 states the rules (one artifact, Not Found, orchestrator updates state)
for a in .claude/agents/0[1-7]-*; do grep -q 'exactly one artifact' $a && grep -q 'Not Found' $a && grep -q 'orchestrator updates' $a && echo "OK   $a" || echo "FAIL $a"; done
# E5 rework and gate rules present
grep -c 'After 2 such loops' .claude/commands/run-sdlc-workflow.md
grep -c 'REJECT' .claude/commands/run-sdlc-workflow.md
```
Expected at step 5: E3 shows 01-04 OK; 05-08 MISSING until later steps run (05 is written by this step). Full 8/8 is checked by step 7.
