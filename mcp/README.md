# MCP server configs

Example MCP server configurations (sanitized — **no secrets**). Use these as starting points for `.mcp.json` in your projects or `~/.claude.json`.

## Files

- [`example.mcp.json`](./example.mcp.json) — a starter `.mcp.json` with placeholders for common servers.

## Safety

- **Never commit real tokens, API keys, or credentials here.** The `.gitignore` blocks `*.secret.*` and `**/secrets.json` as a safety net, but the responsibility is on you.
- Use environment variables (`${env:GITHUB_TOKEN}`) in configs rather than literal values.
- If you accidentally commit a secret: rotate it immediately, then rewrite history with `git filter-repo` (don't just delete the file in a new commit — the secret stays in history).

## Installing in a project

```bash
cp mcp/example.mcp.json /path/to/your/project/.mcp.json
# then edit to enable only the servers you need and supply real values via env vars
```
