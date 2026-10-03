# Workflow state
- State file: `docs/<STORY-ID>/pipeline-state.json`. Each step has a status: `pending`, `in_progress`, `awaiting_approval`, `approved` or `rejected`.
- A step starts only when the previous step is `approved`.
- Subagents never edit `pipeline-state.json` and never approve; the orchestrator updates it. The user delegated approve/reject to the orchestrator (real-output check). Step 8 (PR) needs explicit user approval.
- Statuses also include `rejected`. Approve or reject based on the real pipeline output (checks in the run command), never on an agent's claim. Each step line in the state file is short: `mark` (🟢 approved, ⏳ working or waiting, 🔴 rejected, ⚪ pending), `agent` file name, `artifact`, `status`.
- After each approval the orchestrator stops, shows the flow and the next agent, and waits for the user to say run.
- Artifacts are concise: short bullets and tables, no filler.
- Review steps (3, 6, 7) that find problems send the pipeline back to the step that must fix them. The fixing step and all later steps are reset to `pending`. After 2 loops the orchestrator asks the user.
- The pipeline-guard hook blocks any subagent write to the state file.
- Read the state file before each step and update it after.
