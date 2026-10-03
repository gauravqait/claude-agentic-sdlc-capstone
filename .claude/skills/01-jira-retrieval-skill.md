# Skill: Jira Retrieval

**Used by:** pipeline start (`/run-sdlc-workflow`) and `01-requirements` agent.

Input: a story ID (e.g. `KAN-4`).

0. Check the ID matches `^[A-Z][A-Z0-9]+-[0-9]+$`. If not, stop and tell the user: `Invalid story ID`. Make no MCP call.
1. Call `mcp__atlassian__getJiraIssue` with cloudId `thegauravqa.atlassian.net`, the story ID, and `responseContentFormat: markdown`.
2. If the call fails, returns an error, or returns an empty result (no summary and no description), stop and tell the user: `Story not found` or the MCP error. Do not write any file and do not invent content.
3. Write `context/workflow-context.json`:
   ```json
   {
     "storyId": "KAN-4",
     "summary": "",
     "description": "",
     "acceptanceCriteria": [],
     "labels": [],
     "status": ""
   }
   ```
   This is the only file the story fields are written to. Fill only what Jira returned. Mark missing fields as `"Not Found"`.
4. Create `docs/<STORY-ID>/` if it does not exist.
5. Reply with the summary and the number of acceptance criteria found.
