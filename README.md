# Agentic SDLC Capstone (Claude Code)

Turns a Jira story into eight reviewed SDLC documents and a pull request, using Claude Code subagents, skills, hooks and MCP. A human approves between every step.

## Setup
1. Create a GitHub token with `repo` scope and save it: `setx GITHUB_PAT "<token>"` (see `.env.example`).
2. Start Claude Code in this folder and approve the `atlassian` and `github` MCP servers.

## Run
```
/run-sdlc-workflow KAN-4
```
Output goes to `docs/KAN-4/`.

## Pipeline
| Step | Agent | Output |
|---|---|---|
| 1 | 01-requirements | 01-requirements.md |
| 2 | 02-architecture | 02-architecture.md |
| 3 | 03-design-review | 03-design-review.md |
| 4 | 04-implementation-planner | 04-impl-plan.md |
| 5 | 05-implementation | 05-implementation-summary.md |
| 6 | 06-code-review | 06-code-review.md |
| 7 | 07-verification | 07-verification-report.md |
| 8 | 08-pr-creator | 08-pr-summary.md + pull request |

## Structure
```
.claude/
  agents/     the 8 subagents
  commands/   run-sdlc-workflow
  skills/     jira retrieval, PR validation
  hooks/      secret check, approval guard
  rules/      code quality, git, secrets, workflow state
context/      shared story context
docs/<STORY-ID>/   generated artifacts and pipeline-state.json
```
