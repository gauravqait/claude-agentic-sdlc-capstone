# Workflow state
- State file: `docs/<STORY-ID>/pipeline-state.json`. Read it before each step, update it after.
- Step status: `pending`, `in_progress`, `awaiting_approval`, `approved` or `rejected`. Each step line is short: `mark` (🟢 approved, ⏳ working or waiting, 🔴 rejected, ⚪ pending), `agent`, `artifact`, `status`.
- A step starts only when the previous step is `approved`.
- Only the orchestrator edits the state file and approves. The user delegated approve/reject to it; it decides from real output (checks in the run command), never from an agent's claim. Step 8 (PR) needs explicit user approval.
- After each approval the orchestrator stops, shows the flow and the next agent, and waits for the user to say run.
- Review steps (3, 6, 7) that find problems send the pipeline back to the step that must fix them. That step and all later steps reset to `pending`. After 2 loops the orchestrator asks the user.
- The pipeline-guard hook blocks subagent writes to the state file.
