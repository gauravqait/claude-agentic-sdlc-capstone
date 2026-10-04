# Workflow state
- State file: `docs/<STORY-ID>/pipeline-state.json`. Read it before each step, update it after.
- Step status: `pending`, `in_progress`, `awaiting_approval`, `approved` or `rejected`. Each step line is short: `mark` (🟢 approved, ⏳ working or waiting, 🔴 rejected, ⚪ pending), `agent`, `artifact`, `status`.
- A step starts only when the previous step is `approved`.
- Only the orchestrator edits the state file and approves. The user delegated approve/reject to it; it decides from real output (checks in the run command), never from an agent's claim. Step 8 (PR) needs explicit user approval.
- After each approval the orchestrator shows the board and starts the next agent. It stops only before step 8, after 2 rejections of one step, on an agent question, or when the user asks.
- Approved means frozen: later steps read earlier artifacts and never reopen or re-review them. There is no loop back to an earlier step.
- Review steps (3, 6, 7) with a blocking finding (High, or Correctness/Security/AC failures) are `rejected`: the same agent re-runs with only the failed items. Medium/Low findings are Forward notes passed to the next step. After 2 rejections of one step the orchestrator asks the user.
- Reject a step only for an objective failed check (missing file or AC, invented data, secret, wrong scope). Length and style are never reasons.
- The pipeline-guard hook blocks subagent writes to the state file.
