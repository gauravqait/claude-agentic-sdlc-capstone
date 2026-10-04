# Fetch tests (KAN-5 AC 1)
Run from the repo root in Git Bash. The fetch is a skill (rules in markdown), so each test checks the rule is written; `want N` is the expected count.

```bash
S=.claude/skills/01-jira-retrieval-skill.md; C=.claude/commands/run-sdlc-workflow.md
# Success: skill saves story.json with the required fields
grep -c 'docs/<STORY-ID>/story.json' $S | sed 's/^/want >=1: /'
grep -c 'acceptanceCriteria' $S | sed 's/^/want 1: /'
# Failure 1: fetch error -> Not Found, no file
grep -c 'fetch error.*Not Found.*Write no `story.json`' $S | sed 's/^/want 1: /'
# Failure 2: empty story
grep -c 'empty result' $S | sed 's/^/want 1: /'
# Failure 3: no acceptance criteria
grep -c 'no acceptance criteria' $S | sed 's/^/want 1: /'
# Orchestrator stops and writes no story.json on failure
grep -c 'no acceptance criteria) stop, report `Not Found` and write no `story.json`' $C | sed 's/^/want 1: /'
# Edge: no story.json is committed for a story whose fetch failed (ID that cannot exist)
ls docs/ZZZ-0/story.json 2>/dev/null | wc -l | sed 's/^/want 0: /'
```
