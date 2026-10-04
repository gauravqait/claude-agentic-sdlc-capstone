# KAN-5 · Implementation
Step 5/8 · 🟢 approved

Pipeline rules, readiness checks (a)-(f) and the secret-pattern hook were updated per the plan, with four new test files. All `want` lines matched when run (a few sections are checks that the rules are written, not live runs).

## Tasks
| Task | Result | AC |
|---|---|---|
| T1 | Done. Fetch stops with `Not Found` and writes no `story.json` on error, empty story, no ACs | 1 |
| T2 | No change needed. Agents 1-7 already name one artifact (verified in `tests/artifacts-test.md`) | 2-8, 10 |
| T3 | No change needed. Agent 07 already has Status column and `Verdict:` line | 8 |
| T4 | Done. Scope rejection and one-active-run rule added | 10, 11 |
| T5 | Done. Gate rule added to command; loop-back, 2-loop, guard already in `workflow-state.md` | 11 |
| T6 | No change needed. Agent 08 already does 8a draft / 8b create | 9, 12 |
| T7 | Done. Checks (a)-(f) in the validation skill; hook extended with `gho_`, `ghs_`, `ATATT`, `Bearer `, PEM header | 12 |
| T8-T11 | Done. Tests written and run | 1-12 |
| T12 | Not mine: step 7 records the verification report | 8, 12 |

## Files changed
| File | Why |
|---|---|
| `.claude/skills/01-jira-retrieval-skill.md`, `.claude/commands/run-sdlc-workflow.md` | T1, T4, T5 |
| `.claude/skills/02-pr-validation-skill.md`, `.claude/hooks/check-secrets.sh` | T7 |
| `tests/fetch-test.md`, `artifacts-test.md`, `gates-test.md`, `readiness-test.md` (new) | T8-T11 |
| `tests/hooks-test.md` | Added prefix cases and blocked-start case |

## Deviations
- T2, T3, T6: already met, so no edit.
- Checks (a)-(c) need live GitHub MCP: definitions only, live run `Not Found`.
- Tests of rule text use grep on the markdown; hook and scope tests run for real.

## Run the tests
From the repo root in Git Bash, run the `bash` blocks of each file in `tests/` (`fetch-test.md`, `artifacts-test.md`, `gates-test.md`, `readiness-test.md`, `hooks-test.md`) and compare with each `want`. `artifacts-test.md` section 2 lists later artifacts as `Not Found` until the story is finished.
