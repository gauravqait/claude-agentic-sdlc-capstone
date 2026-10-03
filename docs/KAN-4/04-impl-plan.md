# KAN-4 · Implementation Plan
`Step 4/8` · 🟢 approved

**Summary:** 10 small tasks harden the existing `.claude/` files to meet AC 1-12 and the review fixes (R1, R2, G1-G4, S1). Ordered by dependency, then priority. Paths under `.claude/`.

| ID | Task | Files | Pri | Depends on | Done when | Status |
|----|------|-------|-----|------------|-----------|--------|
| T1 | Jira skill: write story fields only to context file; stop on failure, empty result or bad ID (AC 1; G3, S1) | `skills/01-jira-retrieval-skill.md`, `context/workflow-context.json` | P1 | none | Valid ID fills file; bad ID or MCP error stops with message | pending |
| T2 | Guard hook: only orchestrator/user may set `approved`; step N needs N-1 `approved` (AC 11; R1) | `hooks/pipeline-guard.sh`, `settings.json` | P1 | none | Subagent edit to `approved` is blocked; skipped step is blocked | pending |
| T3 | Secrets hook also scans `context/` (S1) | `hooks/check-secrets.sh`, `settings.json` | P1 | none | Fake token in context file is blocked | pending |
| T4 | Orchestrator: create `docs/<ID>/`, run steps in order, gate after every agent, require non-empty artifact (AC 2-11; G1, G4) | `commands/run-sdlc-workflow.md` | P1 | T1, T2 | Empty file fails; gate shown after each agent | pending |
| T5 | Rework rule: reset fixing step and later to `pending`; ask user after 2 loops (G2) | `commands/run-sdlc-workflow.md`, `rules/workflow-state.md` | P2 | T4 | Third failed loop asks the user | pending |
| T6 | PR agent and validation skill: base `main`, feature head, 5 sections, stop on MCP error (AC 9, 12; R2) | `agents/08-pr-creator.agent.md`, `skills/02-pr-validation-skill.md` | P1 | none | Missing section or wrong base is rejected; MCP error stops | pending |
| T7 | Agents 01-07: confirm each writes one artifact, uses `Not Found`, and sets `awaiting_approval` (AC 2-8) | `agents/01-*.md` to `07-*.md` | P2 | T2 | Each agent file states these three rules | pending |
| T8 | Test: hook tests (skipped step, subagent approve, secret, commit to `main`) | `tests/hooks-test.md` | P2 | T2, T3 | All 4 cases blocked and logged | pending |
| T9 | Test: dry run with KAN-4 and a bad ID; check 8 artifacts in `docs/KAN-4/` (AC 1-11) | `tests/e2e-test.md` | P2 | T4, T5, T7 | Bad ID stops; 8 non-empty files | pending |
| T10 | Test: PR validation cases (good body, missing section, wrong base) without creating a real PR (AC 12) | `tests/pr-test.md` | P3 | T6 | 3 cases give expected result | pending |

## Decisions
- Tests go in root `tests/` (as in the reference layout). Existing `.claude/` files are edited, not rewritten.
