---
description: Run the agentic SDLC pipeline for a Jira story. Usage - /run-sdlc-workflow KAN-4
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
4. **Pass → approve** (user-delegated): `status` `approved`, `mark` 🟢, update `progress` and `next`, commit `docs($ARGUMENTS): <artifact>`.
   **Fail → REJECT:** `status` `rejected`, `mark` 🔴, list the failed checks, call the same subagent again with them. After 2 rejections of one step, ask the user.
5. Steps 6 and 7 that report problems send the pipeline back to `05-implementation`: that step and all later ones reset to `pending` (⚪). After 2 such loops, ask the user.
6. **Stop.** Show the board below and name the next agent. Continue only when the user says so.

```
KAN-4 · 5/8 approved
🟢 1 requirements   🟢 2 architecture   🟢 3 design-review
🟢 4 impl-plan      🟢 5 implementation ⚪ 6 code-review
⚪ 7 verification   ⚪ 8 pr-creator
Next: 06-code-review
```
🟢 approved · ⏳ working or awaiting · 🔴 rejected · ⚪ pending

Step 8 raises the PR only after the user explicitly approves. Show the PR link at the end.
