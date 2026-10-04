# Agentic SDLC Capstone (Claude Code)

A Jira story ID (`<STORY-ID>`) goes in. Eight agents run in order, each writing one artifact to
`docs/<STORY-ID>/`. The orchestrator approves or rejects each step from real output; subagents never approve.
The last agent raises a PR through GitHub MCP.

Run: `/run-sdlc-workflow <STORY-ID>`

| # | Agent | Artifact |
|---|-------|----------|
| 1 | 01-requirements | 01-requirements.md |
| 2 | 02-architecture | 02-architecture.md |
| 3 | 03-design-review | 03-design-review.md |
| 4 | 04-implementation-planner | 04-impl-plan.md |
| 5 | 05-implementation | 05-implementation-summary.md |
| 6 | 06-code-review | 06-code-review.md |
| 7 | 07-verification | 07-verification-report.md |
| 8 | 08-pr-creator | 08-pr-summary.md |

## Rules
- Each story is isolated: its files live in `docs/<STORY-ID>/` and its work on its own `feature/<story-id>-<slug>` branch. Never edit or overwrite another story.
- A phase starts only after the previous one is approved. Step 8 (PR) needs explicit user approval.
- Never write secrets anywhere.
- Jira only via the `atlassian` MCP server, PRs only via the `github` MCP server.
- Details: `.claude/rules/`.
