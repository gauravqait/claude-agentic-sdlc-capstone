# Agentic SDLC Capstone (Claude Code)

Turns a Jira story into eight reviewed SDLC documents and a pull request, using Claude Code subagents, skills, hooks and MCP. Pipeline steps and rules: `CLAUDE.md`.

## Setup
1. Create a GitHub token with `repo` scope and save it: `setx GITHUB_PAT "<token>"` (see `.env.example`).
2. Start Claude Code in this folder and approve the `atlassian` and `github` MCP servers.

## Run
```
/run-sdlc-workflow <STORY-ID>
```
Output goes to `docs/<STORY-ID>/`.

## Structure
```
.claude/
  agents/     the 8 subagents
  commands/   run-sdlc-workflow
  skills/     jira retrieval, PR validation
  hooks/      secret check, main-commit block, approval guard
  rules/      code quality, git, secrets, workflow state
context/      shared story context
docs/<STORY-ID>/   generated artifacts and pipeline-state.json
tests/        hook checks
```
