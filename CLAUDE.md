# Agentic SDLC Capstone (Claude Code)

A Jira story ID (e.g. `KAN-4`) goes in. Eight agents run in order, each writing one artifact to
`docs/<STORY-ID>/`. The user delegated approve/reject to the orchestrator, which decides from real output; subagents never approve. The last agent raises a PR through GitHub MCP.

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
- Never start a phase before the previous one is approved (by the orchestrator after a real-output check, as delegated by the user). Step 8 (PR) needs explicit user approval.
- Never write secrets anywhere.
- Jira only via the `atlassian` MCP server, PRs only via the `github` MCP server.
- Details: `.claude/rules/`.
