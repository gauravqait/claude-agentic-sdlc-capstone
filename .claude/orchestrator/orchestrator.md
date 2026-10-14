# SDLC Orchestrator
Runs in the main session (subagents cannot start subagents). Input: `<STORY-ID>`.
Delegate every step to its subagent with the Agent tool. Never do a step yourself.

## Setup
1. No `docs/<STORY-ID>/story.json`: run `.claude/skills/01-jira-retrieval-skill.md`. On any failure (bad ID, MCP error, empty story, no ACs) stop, report `Not Found`, write no `story.json`.
2. State file `docs/<STORY-ID>/pipeline-state.json` (format: `.claude/rules/workflow-state.md`): create if missing, else resume at the first step not `approved`. A step `in_progress` from another run: stop and tell the user.

## Steps
| # | Subagent | Artifact |
|---|----------|----------|
| 1 | 01-requirements | 01-requirements.md |
| 2 | 02-architecture | 02-architecture.md |
| 3 | 03-design-review | 03-design-review.md |
| 4 | 04-implementation-planner | 04-impl-plan.md |
| 5 | 05-implementation | 05-implementation-summary.md |
| 6 | 06-code-review | 06-code-review.md |
| 7 | 07-verification | 07-verification-report.md |
| 8 | 08-pr-creator | 08-pr-summary.md |

Step N+1 starts only when step N is `approved`.

## Per step
1. Set `in_progress` (⏳). Call the subagent with the story ID and previous artifact paths only. Questions: ask the user, call again with the answers.
2. Show a short artifact summary, its path and the `docs/<STORY-ID>/` file list.
3. Check the real output, not the agent's claim:
   - file exists and is non-empty
   - covers every Jira AC and the previous artifact
   - nothing invented (`Not Found` where missing)
   - no secrets
   - only the expected file changed, inside `docs/<STORY-ID>/` (step 5 may also change code and tests; steps 5-7 need real code, test output or findings)
4. Pass: set `approved`, commit `docs(<STORY-ID>): <artifact>`. Approved steps are frozen.
   Fail: set `rejected`, list only the failed checks, call the same subagent again. After 2 rejections of one step, ask the user.
5. Review steps (3, 6, 7): a blocking finding rejects the step (no loop back); Medium/Low findings go forward as notes.
6. Show the board and start the next step. Stop only before step 8, after 2 rejections of one step, on an agent question, or when the user asks.

## Board
```
<STORY-ID> · 5/8 approved
🟢 1 requirements   🟢 2 architecture   🟢 3 design-review
🟢 4 impl-plan      🟢 5 implementation ⚪ 6 code-review
⚪ 7 verification   ⚪ 8 pr-creator
Next: 06-code-review
```
🟢 approved · ⏳ working or awaiting · 🔴 rejected · ⚪ pending

## Step 8
Run readiness checks (a)-(f) in `.claude/skills/02-pr-validation-skill.md`. A failed check blocks, names the check and stops for the user. The PR needs explicit user approval. Show the PR link when done.
