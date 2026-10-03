# KAN-4 · Design Review
`Step 3/8` · 🟢 approved

**Verdict:** all 12 ACs are covered. Gaps are in enforcement and failure handling. Fixes are already in `02-architecture.md`.

| ID | Sev | Problem (AC) | Fix |
|----|-----|--------------|-----|
| R1 | High | Approval is only a convention (11) | Guard hook: `approved` set only by orchestrator/user, never a subagent |
| R2 | High | PR failure path undefined (12) | Check base `main`, feature head, 5 sections; stop on MCP error |
| G1 | Med | Gate not shown after every agent (11) | Gate after each agent |
| G2 | Med | Rework rule undefined (11) | Reset fixing step and later; stop after 2 loops |
| G3 | Med | Jira empty result or bad ID not handled (1) | Stop and report |
| S1 | Med | Context file could hold tokens (1) | Story fields only; secrets hook scans it |
| G4 | Low | Empty file passes "exists" (2–9) | Require non-empty |

Not actioned: parallel runs would share `context/` (out of scope).

## Decisions to confirm
- Loop limit: **2** · Approver: **orchestrator after self-check** (step 8 needs the user) · `context/` stays **tracked and secret-scanned**.
