---
name: pr-validation
description: Validate docs/<STORY-ID>/08-pr-summary.md against the PR rules and report PASS or FAIL per check. Use before raising a pull request.
argument-hint: <STORY-ID>
---

# PR Validation

Input: `<STORY-ID>`. Read `docs/<STORY-ID>/08-pr-summary.md` and report PASS or FAIL for each check:

| # | Check |
|---|-------|
| 1 | Sections present: Summary, Changes Made, Test Evidence, Known Limitations, Reviewer Checklist |
| 2 | Summary is 2-3 sentences |
| 3 | Changes Made lists each changed file with a reason (compare with `git diff --name-only <base>...HEAD`) |
| 4 | Test Evidence is real output from `07-verification-report.md`, no placeholders |
| 5 | Known Limitations lists every `Not Found` and out-of-scope item |
| 6 | Reviewer Checklist has at least one `- [ ]` item |
| 7 | Base is the repo default branch; head matches `feature/<story-id>-<slug>` |
| 8 | No secrets (token prefixes, `Bearer `, `.env` values) |

Any FAIL: list the fixes and do not raise the PR.
