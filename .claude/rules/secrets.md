# Secrets
- Tokens live only in environment variables (e.g. `GITHUB_PAT`) or a git-ignored `.env`. Commit only `.env.example`.
- Never write a secret into any file, commit, PR or chat. Use `${VAR}` in `.mcp.json`.
- If a secret is found, report the file and line (not the value) and ask the user to rotate it.
