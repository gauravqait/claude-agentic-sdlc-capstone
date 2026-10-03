# Skill: PR Validation

**Used by:** `08-pr-creator` agent, before the PR is raised.

Check `docs/<STORY-ID>/08-pr-summary.md` and report PASS or FAIL per item:

1. Has all five sections: Summary, Changes Made, Test Evidence, Known Limitations, Reviewer Checklist.
2. Summary is 2-3 sentences.
3. Changes Made lists every file added or changed, each with a reason.
4. Test Evidence contains real test output from `07-verification-report.md`, not placeholders.
5. Known Limitations lists every `Not Found` or out-of-scope item.
6. Reviewer Checklist has at least one unchecked `- [ ]` item.
7. Base branch is `main` and head branch matches `feature/<story-id>-<slug>`.
8. No secrets: no `ghp_`, `github_pat_`, `Bearer `, or `.env` values.

If any item fails, list the fixes and do not raise the PR.
