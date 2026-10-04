# KAN-5 · Implementation Plan
Step 4/8 · 🟢 approved

Ordered tasks to make the existing pipeline files (`.claude/`) meet AC 1-12; each task has a test. Tests follow the existing `tests/hooks-test.md` layout: a markdown file per area, Git Bash snippets run from the repo root, each printing a `want N` line. New files sit alongside `hooks-test.md`.

## Fixed planning inputs (from design review)
| Input | Decision |
|---|---|
| RISK-7 · check (e) patterns | Prefixes only: GitHub `ghp_`, `gho_`, `ghs_`, `github_pat_`; Atlassian API token `ATATT`; also `Bearer ` followed by a long token, and `-----BEGIN` + `PRIVATE KEY`. Report file and line only, never the value. Other vendor prefixes: Not Found |
| RISK-8 · check (d) failed test entry | Verification report test table has a `Status` column; any row with `FAIL` is a failed entry. Pass needs a `Verdict: PASS` line and zero `FAIL` rows |

## Tasks
| ID | Task | Files | P | Depends on | Done when | AC | Status |
|---|---|---|---|---|---|---|---|
| T1 | Story fetch: save `story.json`; on fetch error, empty story or no ACs stop, report `Not Found`, write no file | `.claude/skills/01-jira-retrieval-skill.md`, `.claude/commands/run-sdlc-workflow.md` | P1 | none | Rules written; no `story.json` on failure | 1 | pending |
| T2 | Agents 1-7 each write only their one artifact under `docs/<story-id>/` | `.claude/agents/01..07-*.agent.md` | P1 | none | Each agent file names a single output file | 2-8, 10 | pending |
| T3 | Verification agent: record only checks actually run; test table with `Status` column; `Verdict: PASS/FAIL` line | `.claude/agents/07-verification.agent.md` | P1 | T2 | Format in agent file matches RISK-8 decision | 8 | pending |
| T4 | Orchestrator post-step scope check: only expected file changed, inside `docs/<story-id>/`, else reject; one active run per story | `.claude/commands/run-sdlc-workflow.md` | P1 | T2 | Check and rejection rule present | 10, 11 | pending |
| T5 | Gates: next step only after `approved`; loop-back from steps 3/6/7, reset later steps, ask user after 2 loops; step 8 needs user approval | `.claude/commands/run-sdlc-workflow.md`, `.claude/rules/workflow-state.md` | P1 | T4 | Each rule present; subagent state write blocked | 11 | pending |
| T6 | PR Creator drafts `08-pr-summary.md` only (8a) with five required sections; creation is separate (8b) | `.claude/agents/08-pr-creator.agent.md` | P1 | T3 | Agent drafts, does not create PR | 9, 12 | pending |
| T7 | PR readiness checks (a)-(f) via GitHub MCP, using the fixed patterns above and FAIL format; failure blocks, names check, routes to fixing step | `.claude/skills/02-pr-validation-skill.md`, `.claude/hooks/check-secrets.sh` | P1 | T3, T6 | All six checks defined; (e) uses the fixed patterns above | 12 | pending |
| T8 | Tests, fetch: success; fetch error; empty story; no ACs | `tests/fetch-test.md` (new, beside `tests/hooks-test.md`) | P2 | T1 | Success writes file; 3 failures write none and report `Not Found` | 1 | pending |
| T9 | Tests, artifacts and scope: each of 8 artifacts exists in `docs/<story-id>/`; extra file or file outside folder is rejected | `tests/artifacts-test.md` (new) | P2 | T2, T4 | 8 present; stray file causes reject | 2-10 | pending |
| T10 | Tests, gates: happy order; start blocked when prior not approved; loop-back resets later steps; 3rd loop asks user; step 8 without user approval blocked. Extend the existing pipeline-guard section 3 of `tests/hooks-test.md` for the blocked-start case | `tests/gates-test.md` (new), `tests/hooks-test.md` (extend) | P2 | T5 | All cases pass | 11 | pending |
| T11 | Tests, readiness: each check (a)-(f) one pass case and one fail case; (d) with `FAIL` row and with missing verdict; (e) one case per listed prefix, output has no secret value. Extend section 1 (check-secrets.sh) of `tests/hooks-test.md` with the prefixes | `tests/readiness-test.md` (new), `tests/hooks-test.md` (extend) | P2 | T7 | 12 fail cases block; pass case allows | 12 | pending |
| T12 | Run the tests and record only the real results in the verification report | `docs/<story-id>/07-verification-report.md` (step 7) | P2 | T8-T11 | Report lists only checks actually run | 8, 12 | pending |

BLOCKED until dependency done: T3-T7 and T8-T12 (all with a dependency). T1 and T2 can start now.
