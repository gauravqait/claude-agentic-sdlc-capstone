# KAN-5 · Architecture
Step 2/8 · 🟢 approved

Sequential pipeline: an orchestrator fetches the Jira story via Atlassian MCP, runs 8 single-purpose agents in order, gates each step, and validates PR readiness via GitHub MCP against the drafted PR body before the PR is created.

## Overview
`Jira -(Atlassian MCP)-> story.json -> Agents 1-7 -> Agent 8 drafts 08-pr-summary.md -> Readiness checks (a)-(f) (GitHub MCP) -> User approval -> PR created`
One active run per story, on its own `feature/<story-id>-<slug>` branch.

## Components and Responsibilities
| Component | Responsibility | ACs |
|---|---|---|
| Orchestrator (`/run-sdlc-workflow`) | Fetches story, launches agents in order, approves/rejects from real output, loops back on review findings, owns state file. After each step checks that only the expected artifact changed, inside `docs/<story-id>/`; otherwise rejects the step. Allows one active run per story | 1, 10, 11 |
| Atlassian MCP client | Returns Jira story, saved as `story.json`. On fetch failure, empty story or no ACs: stop pipeline, report `Not Found`, write no `story.json`, invent nothing | 1 |
| Requirements Agent | Writes `01-requirements.md` | 2 |
| Architecture Agent | Writes `02-architecture.md` | 3 |
| Design Review Agent | Writes `03-design-review.md` | 4 |
| Implementation Planner Agent | Writes `04-impl-plan.md` | 5 |
| Implementation Agent | Writes `05-implementation-summary.md` | 6 |
| Code Review Agent | Writes `06-code-review.md` | 7 |
| Verification Agent | Writes `07-verification-report.md` with `Verdict: PASS` or `Verdict: FAIL`; records only the checks it actually runs as test evidence | 8 |
| PR Creator Agent (step 8a) | Drafts `08-pr-summary.md` (the PR body) only; does not create the PR | 9 |
| PR creation (step 8b) | After checks pass and user approves, creates the PR through GitHub MCP | 12 |
| Artifact store `docs/<story-id>/` | Only location for all artifacts and `pipeline-state.json` | 10 |
| State file `pipeline-state.json` | Per-step status (`pending`, `in_progress`, `awaiting_approval`, `approved`, `rejected`); orchestrator-only writes (guard hook blocks subagents) | 11 |
| Approval gate | Step N+1 starts only when step N is `approved`; step 8 also needs explicit user approval; review steps 3, 6, 7 send pipeline back to the fixing step (reset later steps; ask user after 2 loops) | 11 |
| PR readiness check (GitHub MCP) | Runs after the draft, before approval. Any failed check blocks the PR, names the check, and routes back to the step that must fix it (see checks below) | 12 |

PR readiness checks:
| Check | Definition |
|---|---|
| (a) | Feature branch (not main) on remote, latest commits pushed |
| (b) | No merge conflicts with base |
| (c) | Steps 1-7 all `approved` |
| (d) | `07-verification-report.md` has an explicit `Verdict: PASS` line and no failed test entries |
| (e) | Scan diff and artifacts for token patterns; report file and line only, never the value |
| (f) | `08-pr-summary.md` has Summary, Changes Made, Test Evidence, Known Limitations, Reviewer Checklist |

## Technology Choices
| Choice | Why |
|---|---|
| Claude Code subagents + slash command | Native fit: one agent per step, orchestrator controls flow |
| Atlassian MCP | Required by AC 1 for Jira access |
| GitHub MCP | Required by AC 12; only permitted PR path |
| Markdown artifacts + JSON state in git | Simple, reviewable, traceable; no extra infrastructure |
| Hook (pipeline-guard) | Enforces orchestrator-only state writes |

## Data Flow
1. Orchestrator reads state, fetches story (Atlassian MCP) to `story.json`; on failure or no ACs it stops with `Not Found`.
2. For each step 1-7: agent reads prior artifacts, writes its one artifact; orchestrator verifies only that file changed under `docs/<story-id>/`; state = `awaiting_approval`; orchestrator approves (next step) or rejects (rerun / loop back).
3. Step 8a: Agent 8 drafts `08-pr-summary.md`.
4. GitHub MCP runs checks (a)-(f); any failure blocks, names the check, routes back to the fixing step.
5. User approves; step 8b creates the PR.

## Risks
| Risk | Mitigation |
|---|---|
| Agent claims success without output | Orchestrator checks real files/output and that only the expected artifact changed |
| Secrets in artifacts or diff | Check (e), file and line only; tokens only in env vars |
| Review loops never end | Ask user after 2 loops |
| Jira fetch fails or story has no ACs | Stop, report `Not Found`, no `story.json` |
| Concurrent runs on one story | One active run per story, own branch |
| Verification evidence overstated | Report lists only checks actually run |
