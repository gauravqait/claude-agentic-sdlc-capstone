# KAN-4 · Architecture
`Step 2/8` · 🟢 approved

**Idea:** one command runs 8 agents in order. Each writes one file to `docs/<STORY-ID>/`, then waits for approval. No new services.

```
Jira MCP → context file → 01 → ✋ → 02 → ✋ → … → 08 → ✋ → GitHub PR
                          (state in pipeline-state.json)
```

## Components
| Component | Does | AC |
|-----------|------|----|
| `/run-sdlc-workflow` | Creates `docs/<STORY-ID>/`, runs steps in order, checks file is non-empty | 10, 11 |
| Jira retrieval skill | Story → `context/workflow-context.json`; stops on failure, empty result or bad ID | 1 |
| Agents 01–07 | One artifact each | 2–8 |
| Agent 08 | PR summary; PR via `github` MCP (base `main`, 5 sections); stops on error | 9, 12 |
| `pipeline-state.json` | Status: pending, in_progress, awaiting_approval, approved | 11 |
| Hooks and rules | Block skipped approvals, secrets, commits to `main` | 11 |

## Review failure (steps 3, 6, 7)
The fixing step and all later steps reset to `pending`. After 2 failed loops, ask the user.

## Risks
| Risk | Fix |
|------|-----|
| Invented data | `Not Found`; reviews check |
| Approval skipped | Guard hook; previous step must be `approved` |
| Bad state or MCP down | Stop and report |
| Secret leak | Rules and secrets hook |
