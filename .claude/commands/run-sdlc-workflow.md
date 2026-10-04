---
description: Run the agentic SDLC pipeline for a Jira story. Usage - /run-sdlc-workflow <STORY-ID>
argument-hint: <STORY-ID>
---

You are the orchestrator for story **$ARGUMENTS**. Delegate every step to its subagent with the Agent tool. Do not do the steps yourself.

## Setup
1. If `context/workflow-context.json` is missing or for another story, run `.claude/skills/01-jira-retrieval-skill.md`. On any failure (bad ID, MCP error, empty story) stop and tell the user.
2. Create `docs/$ARGUMENTS/pipeline-state.json` if missing (format: `.claude/rules/workflow-state.md`). If it exists, resume at the first step that is not `approved`.

## Steps
`01-requirements`, `02-architecture`, `03-design-review`, `04-implementation-planner`, `05-implementation`, `06-code-review`, `07-verification`, `08-pr-creator`.

For each step:
1. Set it to `in_progress` (⏳) and call the subagent with the story ID and the previous artifact paths only. If it returns questions, ask the user and call it again with the answers.
2. When it finishes, show a short summary of the artifact, its path, and the `docs/$ARGUMENTS/` file list.
3. Check the real output, not the agent's claim: file exists and is non-empty, covers the Jira ACs and the previous artifact, nothing invented (`Not Found` where missing), no secrets. Steps 5 to 7 also need real evidence (code, test output, findings).
4. **Pass → approve:** update the state file, commit `docs($ARGUMENTS): <artifact>`.
   **Fail → reject:** list the failed checks and call the same subagent again with them. After 2 rejections of one step, ask the user.
5. Review steps that report problems: reset and loop back as in `.claude/rules/workflow-state.md`.
6. **Stop.** Show the board below and name the next agent. Continue only when the user says so.

```
<STORY-ID> · 5/8 approved
🟢 1 requirements   🟢 2 architecture   🟢 3 design-review
🟢 4 impl-plan      🟢 5 implementation ⚪ 6 code-review
⚪ 7 verification   ⚪ 8 pr-creator
Next: 06-code-review
```
🟢 approved · ⏳ working or awaiting · 🔴 rejected · ⚪ pending

Show the PR link after step 8.
