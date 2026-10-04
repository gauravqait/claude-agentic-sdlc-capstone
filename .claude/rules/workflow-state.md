# Workflow state
- State file: `docs/<STORY-ID>/pipeline-state.json`. Read it before each step, update it after.
- Step status: `pending`, `in_progress`, `awaiting_approval`, `approved` or `rejected`. Each step line is short: `mark` (🟢 approved, ⏳ working or waiting, 🔴 rejected, ⚪ pending), `agent`, `artifact`, `status`.
- A step starts only when the previous step is `approved`.
- Only the orchestrator edits the state file and approves. The user delegated approve/reject to it; it decides from real output (checks in the run command), never from an agent's claim. Step 8 (PR) needs explicit user approval.
- After each approval the orchestrator shows the board and starts the next agent. It stops only before step 8, after 2 loops, on an agent question, or when the user asks.
- Approved means frozen: later steps read earlier artifacts and never reopen or re-review them.
- Review steps (3, 6, 7) loop back only for blocking findings (High, or Correctness/Security/AC failures). That step and all later steps reset to `pending`; the fixing agent gets only the failed items, and the re-review checks only those items and what changed. Medium/Low findings are Forward notes passed to the next step, never a loop. After 2 loops the orchestrator asks the user.
- Reject a step only for an objective failed check (missing file or AC, invented data, secret, wrong scope). Length and style are never reasons.
- The pipeline-guard hook blocks subagent writes to the state file.
