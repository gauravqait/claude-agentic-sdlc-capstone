---
name: jira-retrieval
description: Fetch a Jira story by ID through the Atlassian MCP and save it to docs/<STORY-ID>/story.json. Use when starting the pipeline or when a story's summary and acceptance criteria are needed.
argument-hint: <STORY-ID>
---

# Jira Retrieval

Input: `<STORY-ID>` (e.g. `ABC-12`).

1. **Validate** the ID against `^[A-Z][A-Z0-9]+-[0-9]+$`. If invalid, stop: `Invalid story ID`. No MCP call.
2. **Find the site**: call `mcp__atlassian__getAccessibleAtlassianResources`, use its cloudId.
3. **Fetch**: call `mcp__atlassian__getJiraIssue` with the cloudId, the ID and `responseContentFormat: markdown`.
4. **Check**: on fetch error, empty result (no summary and no description) or no acceptance criteria, stop with `Not Found` (plus the MCP error if any). Write no `story.json`; invent nothing.
5. **Prepare** `docs/<STORY-ID>/` if missing.
6. **Save** `docs/<STORY-ID>/story.json` with `storyId`, `summary`, `description`, `acceptanceCriteria[]`, `labels[]`, `status`. Fill only what Jira returned; missing fields are `"Not Found"`.
7. **Report** the summary and the acceptance-criteria count.
