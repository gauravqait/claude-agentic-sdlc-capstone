# KAN-5 · Architecture
Step 2/8 · 🟢 approved

Sequential pipeline: an orchestrator fetches the Jira story via Atlassian MCP, runs 8 single-purpose agents in order, gates each step, and validates PR readiness via GitHub MCP before the PR.

## Overview
`Jira -(Atlassian MCP)-> story.json -> Agents 1-7 -> docs/<story-id>/ -> Approval gate after each -> Readiness check (GitHub MCP) -> User approval -> Agent 8 -> PR`

## Components and Responsibilities
| Component | Responsibility | ACs |
|---|---|---|
| Orchestrator (`/run-sdlc-workflow`) | Fetches story, launches agents in order, approves/rejects from real output, loops back on review findings, owns state file | 1, 11 |
| Atlassian MCP client | Returns Jira story, saved as `story.json` | 1 |
| Requirements Agent | Writes `01-requirements.md` | 2 |
| Architecture Agent | Writes `02-architecture.md` | 3 |
| Design Review Agent | Writes `03-design-review.md` | 4 |
| Implementation Planner Agent | Writes `04-impl-plan.md` | 5 |
| Implementation Agent | Writes `05-implementation-summary.md` | 6 |
| Code Review Agent | Writes `06-code-review.md` | 7 |
| Verification Agent | Writes `07-verification-report.md` (includes recorded test output = evidence) | 8 |
| PR Creator Agent | Writes `08-pr-summary.md`, creates PR after readiness passes | 9, 12 |
| Artifact store `docs/<story-id>/` | Only location for all artifacts and `pipeline-state.json` | 10 |
| State file `pipeline-state.json` | Per-step status (`pending`, `in_progress`, `awaiting_approval`, `approved`, `rejected`); orchestrator-only writes (guard hook blocks subagents) | 11 |
| Approval gate | Step N+1 starts only when step N is `approved`; step 8 also needs explicit user approval; review steps 3, 6, 7 send pipeline back to the fixing step (reset later steps; ask user after 2 loops) | 11 |
| PR readiness check (GitHub MCP) | Blocks PR on any failure: (a) feature branch on remote, latest pushed; (b) no conflicts with base; (c) steps 1-7 approved; (d) verification passes; (e) no secrets; (f) PR body has 5 required sections | 12 |

## Technology Choices
| Choice | Why |
|---|---|
| Claude Code subagents + slash command | Native fit: one agent per step, orchestrator controls flow |
| Atlassian MCP | Required by AC 1 for Jira access |
| GitHub MCP | Required by AC 12; only permitted PR path |
| Markdown artifacts + JSON state in git | Simple, reviewable, traceable; no extra infrastructure |
| Hook (pipeline-guard) | Enforces orchestrator-only state writes |

## Data Flow
1. Orchestrator reads state, fetches story (Atlassian MCP) to `story.json`.
2. For each step 1-7: agent reads prior artifacts, writes its one artifact; state = `awaiting_approval`; orchestrator approves (next step) or rejects (rerun / loop back).
3. Before step 8: GitHub MCP runs checks (a)-(f); any failure blocks; user approves; PR created.

## Risks
| Risk | Mitigation |
|---|---|
| Agent claims success without output | Orchestrator checks real files/output |
| Secrets in artifacts or diff | Check (e); tokens only in env vars |
| Review loops never end | Ask user after 2 loops |
| Check (d) pass criteria format | Not Found (defined in verification step) |
