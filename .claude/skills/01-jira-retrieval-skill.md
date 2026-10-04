---
name: jira-retrieval
description: Fetch a Jira story by ID through the Atlassian MCP and save it to context/workflow-context.json. Use when starting the pipeline or when a story's summary and acceptance criteria are needed.
argument-hint: <STORY-ID>
---

# Jira Retrieval

Input: `<STORY-ID>` (e.g. `ABC-12`).

1. **Validate** the ID against `^[A-Z][A-Z0-9]+-[0-9]+$`. If invalid, stop: `Invalid story ID`. No MCP call.
2. **Find the site**: call `mcp__atlassian__getAccessibleAtlassianResources`, use its cloudId.
3. **Fetch**: call `mcp__atlassian__getJiraIssue` with the cloudId, the ID and `responseContentFormat: markdown`.
4. **Check**: on error or empty result (no summary and no description), stop with `Story not found` or the MCP error. Write nothing.
5. **Save** `context/workflow-context.json` with `storyId`, `summary`, `description`, `acceptanceCriteria[]`, `labels[]`, `status`. Fill only what Jira returned; missing fields are `"Not Found"`.
6. **Prepare** `docs/<STORY-ID>/` if missing.
7. **Report** the summary and the acceptance-criteria count.
