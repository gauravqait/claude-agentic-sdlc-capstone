---
description: Run the agentic SDLC pipeline for a Jira story. Usage - /run-sdlc-workflow <STORY-ID>
argument-hint: <STORY-ID>
---

You are the orchestrator for story **$ARGUMENTS**. Delegate every step to its subagent with the Agent tool. Do not do the steps yourself.

## Setup
1. If `docs/$ARGUMENTS/story.json` is missing, run `.claude/skills/01-jira-retrieval-skill.md`. On any failure (bad ID, MCP error, empty story) stop and tell the user.
2. Create `docs/$ARGUMENTS/pipeline-state.json` if missing (format: `.claude/rules/workflow-state.md`). If it exists, resume at the first step that is not `approved`.

## Steps
`01-requirements`, `02-architecture`, `03-design-review`, `04-implementation-planner`, `05-implementation`, `06-code-review`, `07-verification`, `08-pr-creator`.

For each step:
1. Set it to `in_progress` (⏳) and call the subagent with the story ID and the previous artifact paths only. If it returns questions, ask the user and call it again with the answers.
2. When it finishes, show a short summary of the artifact, its path, and the `docs/$ARGUMENTS/` file list.
3. Check the real output, not the agent's claim, against this fixed list: file exists and is non-empty; covers every Jira AC and the previous artifact; nothing invented (`Not Found` where missing); no secrets; only the expected file changed, inside `docs/$ARGUMENTS/` (steps 5 to 7 also need real code, test output or findings).
4. **Pass → approve:** update the state file, commit `docs($ARGUMENTS): <artifact>`. An approved step is frozen; later steps never reopen it.
   **Fail → reject:** list only the failed checks and call the same subagent again with them. After 2 rejections of one step, ask the user.
5. Review steps (3, 6, 7): a blocking finding loops back as in `.claude/rules/workflow-state.md`; Medium/Low findings go forward as notes to the next step.
6. Show the board below and start the next step. Stop only before step 8, after 2 loops, on an agent question, or when the user asks.

```
<STORY-ID> · 5/8 approved
🟢 1 requirements   🟢 2 architecture   🟢 3 design-review
🟢 4 impl-plan      🟢 5 implementation ⚪ 6 code-review
⚪ 7 verification   ⚪ 8 pr-creator
Next: 06-code-review
```
🟢 approved · ⏳ working or awaiting · 🔴 rejected · ⚪ pending

Show the PR link after step 8.
